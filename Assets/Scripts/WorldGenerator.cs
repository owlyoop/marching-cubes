using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class WorldGenerator : MonoBehaviour
{
    [HideInInspector]
    public int numChunksWidth = 16;
    [HideInInspector]
    public int numChunksLength = 16;
    [HideInInspector]
    public int numChunksHeight = 4;

    bool worldIsGenerated = false;

    Dictionary<Vector3Int, Chunk> chunks = new Dictionary<Vector3Int, Chunk>();

    public WorldGenGraph worldGraph;

    //public enum IsoAlgorithm { MarchingCubes, DualContouring};
    //public IsoAlgorithm isoSurfaceAlgorithm = IsoAlgorithm.MarchingCubes;

    [Header("Terrain Settings")]
    public float surfaceLevel = 0f; //Negative is air, Positive is depth.
    public bool smoothTerrain;
    public bool flatShading;

    public Material worldMaterial;


    private void Start()
    {
        DestroyWorldInPlayMode();
        GenerateWorld();
    }

    private void Initialize()
    {
        worldGraph.GetEndNode();
        worldGraph.endNode.GetAllNoiseNodes();
        numChunksLength = worldGraph.GetNumChunksLength();
        numChunksWidth = worldGraph.GetNumChunksWidth();
        numChunksHeight = worldGraph.GetNumChunksHeight();
        //isoSurfaceAlgorithm = worldGraph.GetIsoSurfaceType();
    }

    void Generate()
    {
        DestroyWorldInEditor();

        for (int x = 0; x < numChunksWidth; x++)
        {
            for (int z = 0; z < numChunksWidth; z++)
            {
                for (int y = 0; y < numChunksHeight; y++)
                {
                    Vector3Int chunkPos = new Vector3Int(x * GameData.ChunkWidth, y * GameData.ChunkHeight, z * GameData.ChunkWidth);
                    chunks.Add(chunkPos, new Chunk(this, chunkPos, smoothTerrain, flatShading));
                    chunks[chunkPos].chunkObject.transform.SetParent(transform);
                }
            }
        }

        worldIsGenerated = true;
        Debug.Log(string.Format("{0} x {0} x {1} world generated.", numChunksWidth * GameData.ChunkWidth, numChunksHeight * GameData.ChunkHeight));
        //ErodeWorld();
        UpdateDirtyChunks();
    }

    public void DestroyWorldInEditor()
    {
        foreach (KeyValuePair<Vector3Int, Chunk> ch in chunks)
        {
            DestroyImmediate(ch.Value.chunkObject);
        }
        chunks.Clear();
        worldIsGenerated = false;
    }

    public void DestroyWorldInPlayMode()
    {
        foreach (KeyValuePair<Vector3Int, Chunk> ch in chunks)
        {
            Destroy(ch.Value.chunkObject);
        }
        chunks.Clear();
        worldIsGenerated = false;
    }

    public Chunk GetChunkFromVector3(Vector3 pos)
    {
        int x = (int)pos.x;
        int y = (int)pos.y;
        int z = (int)pos.z;

        //Debug.Log("GetChunkFromVector3 v3 param is " + pos.ToString());

        if (x < 0 || y < 0 || z < 0 || x >= numChunksWidth * GameData.ChunkWidth || y >= numChunksHeight * GameData.ChunkHeight || z >= numChunksWidth * GameData.ChunkWidth)
        {
            return null;
        }
        else
        {
            //Debug.Log("GetChunkFromVector3 return is" + new Vector3Int(x,y,z).ToString());
            return chunks[new Vector3Int(x, y, z)];
        }
        
    }

    public Chunk RoundWorldCoordsToGetChunk(int x, int y, int z)
    {
        if (x < 0 || y < 0 || z < 0)
            return null;
        x = x - (x % GameData.ChunkWidth);
        y = y - (y % GameData.ChunkHeight);
        z = z - (z % GameData.ChunkWidth);

        //Debug.Log("Rounded down to: " + x.ToString() + " " + y.ToString() + " " + z.ToString());
        if (x >= numChunksWidth * GameData.ChunkWidth || y >= numChunksHeight * GameData.ChunkHeight || z >= numChunksWidth * GameData.ChunkWidth)
        {
            return null;
        }
        else
        {
            return chunks[new Vector3Int(x, y, z)];
        }
            
    }

    public float GetTerrainMapValueFromWorldPos(int x, int y, int z)
    {
        Chunk chunk = RoundWorldCoordsToGetChunk(x,y,z);

        if (chunk != null)
        {
            float value = chunk.terrainMap[x % GameData.ChunkWidth, y % GameData.ChunkHeight, z % GameData.ChunkWidth];
            //Debug.Log("GetTerrainMapValueFromWorldPos Value is " + value.ToString());
            return value;
        }
        else
        {
            return 2;
        }
    }

    //TODO: Move the alter terrain function here. I should be able to alter terrain just from a world pos, i sohuldnt need to know what chunk to do it on beforehand
    public void AlterTerrain(Vector3 worldPos, bool isDigging, float amount, int outerRings, bool updateMesh)
    {
        float newTerrainValue;
        if (isDigging)
            newTerrainValue = amount;
        else newTerrainValue = -amount;

        int x = Mathf.RoundToInt(worldPos.x);
        int y = Mathf.RoundToInt(worldPos.y);
        int z = Mathf.RoundToInt(worldPos.z);

        Chunk chunk = RoundWorldCoordsToGetChunk(x,y,z);

        if (chunk != null)
        {
            chunk.AlterTerrain(worldPos, isDigging, amount, updateMesh);

            for (int ring = 0; ring < outerRings; ring++)
            {
                for (int xi = ring - 1; xi < ring + 2; xi++)
                {
                    for (int zi = ring - 1; zi < ring + 2; zi++)
                    {
                        if (xi != 0 && zi != 0)
                        {
                            Chunk c = RoundWorldCoordsToGetChunk(x + xi, y, z + zi);
                            if (c != null)
                            {
                                c.AlterTerrain(new Vector3(x + xi, worldPos.y, z + zi), isDigging, amount, updateMesh);
                            }
                        }
                    }
                }
            }
        }
    }

    public void UpdateDirtyChunks()
    {
        foreach (KeyValuePair < Vector3Int, Chunk > ch in chunks)
        {
            if (ch.Value.isDirty)
            {
                ch.Value.CreateMeshData();
            }
        }
    }

    public void GenerateWorld()
    {
        Initialize();
        Generate();
    }
}

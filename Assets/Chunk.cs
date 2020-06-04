using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chunk
{
    MeshFilter meshFilter;
    MeshCollider meshCollider;
    MeshRenderer meshRend;
    public GameObject chunkObject;
    public WorldGenerator world;

    public Vector3Int chunkPosition;

    List<Vector3> vertices = new List<Vector3>();
    List<int> triangles = new List<int>();

    int width { get { return GameData.ChunkWidth; } }
    int height { get { return GameData.ChunkHeight; } }

    float[,,] terrainMap;

    bool smoothTerrain;
    bool flatShading;
    float noiseScale;

    [Header("Noise Settings")]
    public float scale = 12f;
    public int numOctaves = 8;

    [Header("Erosion Settings")]
    public bool erosionEnabled;
    public int iterations = 200;


    public Chunk(WorldGenerator world, Vector3Int _position, bool _smoothTerrain, bool _flatShading, float _noiseScale)
    {
        chunkObject = new GameObject();
        chunkObject.name = string.Format("Chunk {0}, {1}, {2}", _position.x, _position.y, _position.z);
        chunkPosition = _position;
        chunkObject.transform.position = chunkPosition;
        chunkObject.transform.tag = "Terrain";
        this.world = world;

        smoothTerrain = _smoothTerrain;
        flatShading = _flatShading;
        noiseScale = _noiseScale;

        meshFilter = chunkObject.AddComponent<MeshFilter>();
        meshCollider = chunkObject.AddComponent<MeshCollider>();
        meshRend = chunkObject.AddComponent<MeshRenderer>();
        meshRend.material = Resources.Load<Material>("Materials/Terrain");
        meshRend.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.TwoSided;


        terrainMap = new float[width + 1, height + 1, width + 1];
        GenerateTerrainMap();
        CreateMeshData();
    }

    void CreateMeshData()
    {
        ClearMeshData();
        //Look through each cube of terrain
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                for (int z = 0; z < width; z++)
                {
                    //Float for each corner of a cube. get the value from our terrainmap
                    float[] cube = new float[8];
                    for (int i = 0; i < 8; i++)
                    {
                        Vector3Int corner = new Vector3Int(x, y, z) + GameData.CornerTable[i];
                        cube[i] = terrainMap[corner.x, corner.y, corner.z];
                    }

                    //Pass value into MarchCube
                    MarchCube(new Vector3(x,y,z), cube);
                }
            }
        }

        BuildMesh();
    }

    void ClearMeshData()
    {
        vertices.Clear();
        triangles.Clear();
    }

    void BuildMesh()
    {
        Mesh mesh = new Mesh();
        mesh.vertices = vertices.ToArray();
        mesh.triangles = triangles.ToArray();
        mesh.RecalculateNormals();
        meshFilter.mesh = mesh;
        meshCollider.sharedMesh = mesh;
    }

    void GenerateTerrainMap()
    {
        float thisPoint;
        for (int x = 0; x < width + 1; x++)
        {
            for (int z = 0; z < width + 1; z++)
            {
                for (int y = 0; y < height + 1; y++)
                {

                    thisPoint = GameData.SimplexNoise(x + chunkPosition.x, y + chunkPosition.y, z + chunkPosition.z, noiseScale * 4f);
                    thisPoint += GameData.SimplexNoise(x + chunkPosition.x, y + chunkPosition.y, z + chunkPosition.z, noiseScale);
                    thisPoint += GameData.EvenOutTerrain(x + chunkPosition.x, y + chunkPosition.y, z + chunkPosition.z, world.numChunksHeight);
                    terrainMap[x, y, z] = thisPoint;
                }
            }
        }
    }
    /// <summary>
    /// Raises or Digs the terrain at a single point. Will check if the point is on the chunk border
    /// </summary>
    /// <param name="isDigging"></param>
    /// <param name="pos"></param>
    public void AlterTerrain(bool isDigging, Vector3 pos)
    {
        float newTerrainValue;
        if (isDigging)
            newTerrainValue = 1f;
        else newTerrainValue = -1f;

        Vector3Int tMap = new Vector3Int(Mathf.RoundToInt(pos.x), Mathf.RoundToInt(pos.y), Mathf.RoundToInt(pos.z));
        tMap -= chunkPosition;

        int mapXLength = terrainMap.GetLength(0);
        int mapYHeight = terrainMap.GetLength(1);
        int mapZLength = terrainMap.GetLength(2);

        Debug.Log("Chunk " + chunkObject.name + " altered at " + tMap.x.ToString() + " " + tMap.y.ToString() + " " + tMap.z.ToString());
        terrainMap[tMap.x, tMap.y, tMap.z] += newTerrainValue;


        float worldX = chunkPosition.x;
        float worldY = chunkPosition.y;
        float worldZ = chunkPosition.z;


        //if the point is on an end face, 1 extra chunk has to be updated (not including original chunk)
        //if on edge, 3 extra
        //if on corner, 7 extra

        int border = 0;
        int xValue = -1;
        int yValue = -1;
        int zValue = -1;

        int xInverse = -1;
        int yInverse = -1;
        int zInverse = -1;

        if (tMap.x == 0)
        {
            worldX = chunkPosition.x - GameData.ChunkWidth;
            border++;
            xValue = GameData.ChunkWidth;
            xInverse = 0;
        }
        else if (tMap.x == mapXLength - 1)
        {
            worldX = chunkPosition.x + GameData.ChunkWidth;
            border++;
            xValue = 0;
            xInverse = GameData.ChunkWidth;
        }

        if (tMap.y == 0)
        {
            worldY = chunkPosition.y - GameData.ChunkHeight;
            border++;
            yValue = GameData.ChunkHeight;
            yInverse = 0;
        }
        else if (tMap.y == mapYHeight - 1)
        {
            worldY = chunkPosition.y + GameData.ChunkHeight;
            border++;
            yValue = 0;
            yInverse = GameData.ChunkHeight;
        }

        if (tMap.z == 0)
        {
            worldZ = chunkPosition.z - GameData.ChunkWidth;
            border++;
            zValue = GameData.ChunkWidth;
            zInverse = 0;
        }
        else if (tMap.z == mapZLength - 1)
        {
            worldZ = chunkPosition.z + GameData.ChunkWidth;
            border++;
            zValue = 0;
            zInverse = GameData.ChunkWidth;
        }

        if (border != 0)
        {
            if (border == 1)    //faces. 2 chunks should be altered (1 + the original)
            {
                if (xValue != -1)
                {
                    AlterBorderChunk(new Vector3(worldX, chunkPosition.y, chunkPosition.z), xValue, tMap.y, tMap.z, newTerrainValue);
                }
                else if (yValue != -1)
                {
                    AlterBorderChunk(new Vector3(chunkPosition.x, worldY, chunkPosition.z), tMap.x, yValue, tMap.z, newTerrainValue);
                }
                else if (zValue != -1)
                {
                    AlterBorderChunk(new Vector3(chunkPosition.x, chunkPosition.y, worldZ), tMap.x, tMap.y, zValue, newTerrainValue);
                }
                
            }
            else if (border == 2)   //edges. 4 chunks should be altered (3 + the original)
            {
                if (xValue == -1)
                {
                    AlterBorderChunk(new Vector3(worldX, worldY, worldZ), tMap.x, yValue ,zValue, newTerrainValue);
                    AlterBorderChunk(new Vector3(worldX, chunkPosition.y, worldZ), tMap.x, tMap.y, zValue, newTerrainValue);
                    AlterBorderChunk(new Vector3(worldX, worldY, chunkPosition.z), tMap.x, yValue, tMap.z, newTerrainValue);
                }
                else if (yValue == -1)
                {
                    AlterBorderChunk(new Vector3(worldX, worldY, worldZ), xValue, tMap.y, zValue, newTerrainValue);
                    AlterBorderChunk(new Vector3(chunkPosition.x, worldY, worldZ), tMap.x, tMap.y, zValue, newTerrainValue);
                    AlterBorderChunk(new Vector3(worldX, worldY, chunkPosition.z), xValue, tMap.y, tMap.z, newTerrainValue);
                }
                else if (zValue == -1)
                {
                    AlterBorderChunk(new Vector3(worldX, worldY, worldZ), xValue, yValue, tMap.z, newTerrainValue);
                    AlterBorderChunk(new Vector3(chunkPosition.x, worldY, worldZ), tMap.x, yValue, tMap.z, newTerrainValue);
                    AlterBorderChunk(new Vector3(worldX, chunkPosition.y, worldZ), xValue, tMap.y, tMap.z, newTerrainValue);
                }
            }
            else if (border == 3)   //corners. 8 chunks should be altered (7 + the original)
            {
                AlterBorderChunk(new Vector3(worldX, worldY, worldZ),xValue, yValue, zValue, newTerrainValue);

                AlterBorderChunk(new Vector3(chunkPosition.x, worldY, worldZ), tMap.x, yValue, zValue, newTerrainValue);
                AlterBorderChunk(new Vector3(worldX, chunkPosition.y, worldZ), xValue, tMap.y, zValue, newTerrainValue);
                AlterBorderChunk(new Vector3(worldX, worldY, chunkPosition.z), xValue, yValue, tMap.z, newTerrainValue);

                AlterBorderChunk(new Vector3(chunkPosition.x, chunkPosition.y, worldZ), tMap.x, tMap.y, zValue, newTerrainValue);
                AlterBorderChunk(new Vector3(chunkPosition.x, worldY, chunkPosition.z), tMap.x, yValue, tMap.z, newTerrainValue);
                AlterBorderChunk(new Vector3(worldX, chunkPosition.y, chunkPosition.z), xValue, tMap.y, tMap.z, newTerrainValue);

            }
        }

        CreateMeshData();
    }

    /// <summary>
    /// Helper function for the "AlterTerrain" function.
    /// </summary>
    /// <param name="pos"></param>
    /// <param name="xMap"></param>
    /// <param name="yMap"></param>
    /// <param name="zMap"></param>
    /// <param name="newTerrainValue"></param>
    void AlterBorderChunk(Vector3 pos, int xMap, int yMap, int zMap, float newTerrainValue)
    {
        Chunk borderChunk = world.GetChunkFromVector3(pos);
        if (borderChunk != null)
        {
            Debug.Log("Border " + borderChunk.chunkObject.name + " altered at " + xMap.ToString() + "," + yMap.ToString() + "," + zMap.ToString() + " at time: " + Time.time.ToString());
            borderChunk.terrainMap[xMap, yMap, zMap] += newTerrainValue;
            borderChunk.CreateMeshData();
        }
    }

    //move to gamedata lazy trey
    float Perlin3D(float x, float y, float z)
    {
        float AB = Mathf.PerlinNoise(x, y);
        float BC = Mathf.PerlinNoise(y,z);
        float AC = Mathf.PerlinNoise(x, z);

        float BA = Mathf.PerlinNoise(y,x);
        float CB = Mathf.PerlinNoise(z,y);
        float CA = Mathf.PerlinNoise(z, x);

        float ABC = AB + BC + AC + BA + CB + CA;
        return ABC / 6f;
    }

    void ErodeTerrain(int startY)
    {

    }

    void MarchCube(Vector3 position, float[] cube)
    {
        int configIndex = GetCubeConfig(cube);

        //These 2 configs means that the cube has no triangles
        if (configIndex == 0 || configIndex == 255)
            return;

        //Loop through the triangles. Never more than 5 triangles to a cube and only 3 vertices per triangle
        int edgeIndex = 0;

        for (int t = 0; t < 5; t++)
        {
            for (int v = 0; v < 3; v++)
            {
                //Get current indice. Increment triangle index each loop
                int indice = GameData.TriangleTable[configIndex, edgeIndex];

                //If the indice is -1, that means no more indices for that config and we can exit
                if (indice == -1)
                    return;

                //Get the vertices for the start and end of the edge
                Vector3 vert1 = position + GameData.CornerTable[GameData.EdgeIndexes[indice, 0]];
                Vector3 vert2 = position + GameData.CornerTable[GameData.EdgeIndexes[indice, 1]];

                Vector3 vertPosition;
                
                if (smoothTerrain)
                {
                    //Get terrain values at each end of edge, then interpolate the vert point on the edge
                    float vert1Sample = cube[GameData.EdgeIndexes[indice, 0]];
                    float vert2Sample = cube[GameData.EdgeIndexes[indice, 1]];

                    float difference = vert2Sample - vert1Sample;

                    if (difference == 0)
                        difference = GameData.surfaceLevel;
                    else
                        difference = (GameData.surfaceLevel - vert1Sample) / difference;

                    vertPosition = vert1 + ((vert2 - vert1) * difference);
                }
                else
                {
                    //midpoint of edge
                    vertPosition = (vert1 + vert2) / 2f;
                }

                if (flatShading)
                {
                    vertices.Add(vertPosition);
                    triangles.Add(vertices.Count - 1);
                }
                else
                {
                    triangles.Add(VertForIndice(vertPosition));
                }

                
                edgeIndex++;
            }
        }
    }

    int VertForIndice(Vector3 vert)
    {
        for (int i = 0; i < vertices.Count; i++)
        {
            if (vertices[i] == vert)
                return i;
        }
        vertices.Add(vert);
        return vertices.Count - 1;
    }

    //Gets the config of the cube from the tables based on the points being below the terrain surface
    int GetCubeConfig(float[] cube)
    {
        int index = 0;
        for (int i = 0; i < 8; i++)
        {
            if (cube[i] > GameData.surfaceLevel)
                index |= 1 << i;
        }

        return index;
    }


}
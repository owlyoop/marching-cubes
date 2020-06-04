using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class WorldGenerator : MonoBehaviour
{
    public int numChunksWidth = 16;
    public int numChunksHeight = 4;

    Dictionary<Vector3Int, Chunk> chunks = new Dictionary<Vector3Int, Chunk>();

    [Header("Gizmo Settings")]
    public float gizmoSize = .1f;
    public bool drawGizmos;

    [Header("Terrain Settings")]
    public bool smoothTerrain;
    public bool flatShading;

    [Header("Noise Settings")]
    public float scale = 12f;
    public int numOctaves = 8;

    [Header("Erosion Settings")]
    public bool erosionEnabled;
    public int iterations = 200;


    private void Start()
    {
        Generate();
    }

    void Generate()
    {
        for (int x = 0; x < numChunksWidth; x++)
        {
            for (int z = 0; z < numChunksWidth; z++)
            {
                for (int y = 0; y < numChunksHeight; y++)
                {
                    Vector3Int chunkPos = new Vector3Int(x * GameData.ChunkWidth, y * GameData.ChunkHeight, z * GameData.ChunkWidth);
                    chunks.Add(chunkPos, new Chunk(this, chunkPos, smoothTerrain, flatShading, scale));
                    chunks[chunkPos].chunkObject.transform.SetParent(transform);
                }
            }
        }

        Debug.Log(string.Format("{0} x {0} x {1} world generated.", numChunksWidth * GameData.ChunkWidth, numChunksHeight * GameData.ChunkHeight));
    }

    public Chunk GetChunkFromVector3(Vector3 pos)
    {
        int x = (int)pos.x;
        int y = (int)pos.y;
        int z = (int)pos.z;

        if (x < 0 || y < 0 || z < 0 || x >= numChunksWidth * GameData.ChunkWidth || y >= numChunksHeight * GameData.ChunkHeight || z >= numChunksWidth * GameData.ChunkWidth)
        {
            return null;
        }
        else return chunks[new Vector3Int(x, y, z)];

    }

}

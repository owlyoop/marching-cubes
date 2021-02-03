using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

[CreateAssetMenu]
public class WorldGenGraph : NodeGraph
{

    public WorldGenEndNode endNode;

    [HideInInspector]
    public Vector3 noiseGenPoint;
    public void GetEndNode()
    {
        foreach (Node n in nodes)
        {
            if (n is WorldGenEndNode)
            {
                endNode = (WorldGenEndNode)n;
                break;
            }
        }
    }

    //repeating code. i dont care
    public int GetNumChunksLength()
    {
        foreach (Node n in nodes)
        {
            if (n is WorldGenEndNode)
            {
                return ((WorldGenEndNode)n).length;
            }
        }
        return 0; //TODO: make this an actual error message
    }

    public int GetNumChunksWidth()
    {
        foreach (Node n in nodes)
        {
            if (n is WorldGenEndNode)
            {
                return ((WorldGenEndNode)n).width;
            }
        }
        return 0; //TODO: make this an actual error message
    }

    public int GetNumChunksHeight()
    {
        foreach (Node n in nodes)
        {
            if (n is WorldGenEndNode)
            {
                return ((WorldGenEndNode)n).height;
            }
        }
        return 0; //TODO: make this an actual error message
    }


    /*public WorldGenerator.IsoAlgorithm GetIsoSurfaceType()
    {
        return endNode.isoSurfaceAlgorithm;
    }*/
}
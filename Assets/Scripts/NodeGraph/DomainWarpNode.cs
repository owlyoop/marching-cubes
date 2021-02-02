using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class DomainWarpNode : PreviewableNode
{
    [Input] public float noiseValueInput;
    [Input] public float warpNoiseInput;
    public bool useWarpNoiseInput = false;
    [Range(1, 8)] private int numOctaves = 1;
    public float strength = 10;
    [Output] public float noiseValueOutput;

    // Use this for initialization
    protected override void Init()
    {
		base.Init();
	}


    float fbm(Vector3 p, bool useCustomWarp)
    {
        worldGraph.noiseGenPoint = p;
        float t = 0;

        if (useCustomWarp)
        {
            for (int i = 0; i < numOctaves; i++)
            {
                float f = Mathf.Pow(2.0f, (float)i);
                float a = Mathf.Pow(f, -0.5f);
                t += a * GetInputValue<float>("warpNoiseInput", this.warpNoiseInput);
            }
        }
        else
        {
            for (int i = 0; i < numOctaves; i++)
            {
                float f = Mathf.Pow(2.0f, (float)i);
                float a = Mathf.Pow(f, -0.5f);
                t += a * GetInputValue<float>("noiseValueInput", this.noiseValueInput);
            }
            
        }
        return t;
    }

    float pattern(Vector3 p)
    {
        Vector3 q = new Vector3(fbm(p + new Vector3(0, 0, 0), useWarpNoiseInput)
                        , fbm(p + new Vector3(0, 0, 0), useWarpNoiseInput)
                        , fbm(p + new Vector3(0, 0, 0), useWarpNoiseInput));

        if (!useWarpNoiseInput)
        {
            q = new Vector3(fbm(p + new Vector3(5.2f, 1.3f, 7.7f), useWarpNoiseInput)
                        , fbm(p + new Vector3(0.2f, 0.1f, 0.9f), useWarpNoiseInput)
                        , fbm(p + new Vector3(9.2f, 4.3f, 8.8f), useWarpNoiseInput));
        }

        return fbm(p + (strength * q), false);
    }


    // Return the correct value of an output port when requested
    public override object GetValue(NodePort port)
    {
        return pattern(worldGraph.noiseGenPoint);
	}

    public override void UpdatePreview()
    {
        int s = previewTextureSize;
        int h = (GameData.ChunkHeight * worldGraph.endNode.height);
        Texture2D tex = new Texture2D(s, s);
        float[,] values = new float[s, s];

        for (int x = 0; x < s; x++)
        {
            for (int y = 0; y < s; y++)
            {
                float val = 0;
                worldGraph.noiseGenPoint = new Vector3(x, previewOffset, y);
                Vector3 r = new Vector3(worldGraph.noiseGenPoint.x,
                                worldGraph.noiseGenPoint.y,
                                worldGraph.noiseGenPoint.z);

                val = pattern(r);
                val = Mathf.Clamp(val, -1f, 1f);
                values[x, y] = val;

            }
        }

        for (int x = 0; x < s; x++)
        {
            for (int y = 0; y < s; y++)
            {
                float val = values[x, y];
                float norm = (val + 1f) / 2f;
                tex.SetPixel(x, y, new Color(norm, norm, norm, 1f));
            }
        }

        tex.Apply();
        previewTex = tex;
    }
}
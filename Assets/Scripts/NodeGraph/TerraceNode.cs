﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class TerraceNode : PreviewableNode
{
    [Input] public float noiseInput;
    public int terraceHeight = 4;
    [Output] public float noiseValueOutput;
	// Use this for initialization
	protected override void Init()
    {
		base.Init();
	}

    public float Evaluate(Vector3 point, float i)
    {
        //float value = Mathf.Round(i * terraceHeight)/ terraceHeight;
        float value = -point.y + i + (point.y % terraceHeight);
        return value;
    }

	// Return the correct value of an output port when requested
	public override object GetValue(NodePort port)
    {
        float input = GetInputValue<float>("noiseInput", this.noiseInput);
        return Evaluate(worldGraph.noiseGenPoint, input);
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
                switch (previewDirection)
                {
                    case TexPreviewDirection.Top: default: worldGraph.noiseGenPoint = new Vector3(x, previewOffset, y); break;
                    case TexPreviewDirection.Front: worldGraph.noiseGenPoint = new Vector3(previewOffset, y, x); break;
                    case TexPreviewDirection.Right: worldGraph.noiseGenPoint = new Vector3(x, y, previewOffset); break;
                }
                float val = 0;
                float input = GetInputValue<float>("noiseInput", this.noiseInput);
                val = Evaluate(worldGraph.noiseGenPoint, input);
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
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class RigidNoiseNode : Node
{
    public int seed = 0;
    public float strength = 1;
    [Range(1, 8)] public int numOctaves;
    public float lacunarity = 2;
    public float persistance = 0.5f;
    public float noiseScale = 2.5f;
    public float noiseWeight = 5;
    public float weightMultiplier = 2.5f;
    public Vector3 center;
    public float floorOffset = 0;

    [Output] public float noiseValue;

    Noise noise = new Noise();

    // Use this for initialization
    protected override void Init()
    {
        base.Init();
    }

    public float Evaluate(Vector3 point)
    {
        float currNoise = 0;
        float frequency = noiseScale / 100;
        float amplitude = 1;
        float weight = 1;

        for (int i = 0; i < numOctaves; i++)
        {
            float n = noise.Evaluate(point * frequency + center);
            float v = 1 - Mathf.Abs(n);
            v = v * v;
            v *= weight;
            currNoise += v * amplitude;
            amplitude *= persistance;
            frequency *= lacunarity;
        }

        float finalValue = -((point.y) + floorOffset) + noiseValue * noiseWeight + ((point.y * GameData.ChunkHeight) % 1) * 0;
        finalValue = -finalValue;

        finalValue = Mathf.Clamp(finalValue, -10f, 10f);
        finalValue /= 10f;

        return finalValue * strength;
    }

    // Return the correct value of an output port when requested
    public override object GetValue(NodePort port)
    {
        return null; // Replace this
    }
}

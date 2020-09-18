using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RidgedNoiseFilter : INoiseFilter
{

    NoiseSettings.RidgedNoiseSettings settings;
    Noise noise = new Noise();

    public RidgedNoiseFilter(NoiseSettings.RidgedNoiseSettings settings)
    {
        this.settings = settings;
    }

    public float Evaluate(Vector3 point)
    {
        float noiseValue = 0;

        float frequency = settings.noiseScale / 100;
        float amplitude = 1;
        float weight = 1;

        for (int i = 0; i < settings.numOctaves; i++)
        {
            float n = noise.Evaluate(point * frequency + settings.center);
            float v = 1 - Mathf.Abs(n);
            v = v * v;
            v *= weight;
            weight = Mathf.Max(Mathf.Min(v * settings.weightMultiplier, 1), 0);
            noiseValue += v * amplitude;
            amplitude *= settings.persistance;
            frequency *= settings.lacunarity;
        }

        float finalValue = -((point.y) + settings.floorOffset) + noiseValue * settings.noiseWeight + ((point.y * GameData.ChunkHeight) % 1) * 0;
        finalValue = -finalValue;

        finalValue = Mathf.Clamp(finalValue, -10f, 10f);
        finalValue /= 10f;

        if (settings.onlyNegativeValues)
        {
            if (finalValue > 0)
                finalValue = -finalValue;
        }
        else if (settings.onlyPositiveValues)
        {
            if (finalValue < 0)
                finalValue = Mathf.Abs(finalValue);
        }

        return finalValue * settings.finalStrength;
    }

}

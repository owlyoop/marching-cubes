using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimplexNoiseFilter : INoiseFilter
{
    NoiseSettings.SimplexNoiseSettings settings;
    Noise noise = new Noise();

    public SimplexNoiseFilter(NoiseSettings.SimplexNoiseSettings settings)
    {
        this.settings = settings;
    }

    public float Evaluate(Vector3 point)
    {
        float noiseValue = 0;
        float frequency = settings.baseRoughness;
        float amplitude = 1;

        if (settings.numLayers == 1)
        {
            noiseValue = noise.Evaluate(point * frequency + settings.center);
        }
        else
        {
            for (int i = 0; i < settings.numLayers; i++)
            {
                float v = noise.Evaluate(point * frequency + settings.center);
                noiseValue += (v) * .5f * amplitude;
                frequency *= settings.roughness;
                amplitude *= settings.persistance;
            }
        }
        
        if (settings.onlyNegativeValues)
        {
            if (noiseValue > 0)
                noiseValue = -noiseValue;

            return noiseValue * settings.strength;
        }
        else if (settings.onlyPositiveValues)
        {
            if (noiseValue < 0)
                noiseValue = Mathf.Abs(noiseValue);

            return noiseValue * settings.strength;
        }
        else
        {
            return noiseValue * settings.strength;
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelNoiseFilter : INoiseFilter
{
    NoiseSettings.LevelNoiseSettings settings;
    public LevelNoiseFilter(NoiseSettings.LevelNoiseSettings settings)
    {
        this.settings = settings;
    }
    public float Evaluate(Vector3 pos)
    {
        float noiseValue = 0;

        if (pos.y > settings.yThreshold)
        {
            noiseValue = (float)pos.y / ((float)GameData.ChunkHeight * settings.NumChunksHeight);
            noiseValue /= 1.2f;
        }
        else
        {
            noiseValue = -1 + ((float)pos.y / settings.yThreshold);
        }

        if (pos.y >= (GameData.ChunkHeight * settings.NumChunksHeight) - 1)
            noiseValue = 2f;
        if (pos.y <= 0)
            noiseValue = -2f;

        return noiseValue * settings.strength;
    }
}

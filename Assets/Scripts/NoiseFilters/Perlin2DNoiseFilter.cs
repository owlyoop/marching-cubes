using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Perlin2DNoiseFilter : INoiseFilter
{
    NoiseSettings.Perlin2DNoiseSettings settings;

    public Perlin2DNoiseFilter(NoiseSettings.Perlin2DNoiseSettings settings)
    {
        this.settings = settings;
    }

    public float Evaluate(Vector3 pos)
    {
        throw new System.NotImplementedException();
    }
}

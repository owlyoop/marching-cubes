using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class NoiseSettings
{
    public enum FilterType { Simplex, Ridged, LevelTerrain, Perlin2D};
    public FilterType filterType;

    [ConditionalHide("filterType", 0)]
    public SimplexNoiseSettings simplexNoiseSettings;
    [ConditionalHide("filterType", 1)]
    public RidgedNoiseSettings ridgedNoiseSettings;
    [ConditionalHide("filterType", 2)]
    public LevelNoiseSettings levelNoiseSettings;

    [System.Serializable]
    public class SimplexNoiseSettings
    {
        public bool onlyNegativeValues = false;
        public bool onlyPositiveValues = false;
        public float strength = 1;
        [Range(1, 8)]
        public int numLayers = 1;
        public float baseRoughness = 1;
        public float roughness = 2;
        public float persistance = .5f;
        public Vector3 center;
        public int seed = 0;
    }

    [System.Serializable]
    public class RidgedNoiseSettings
    {
        public bool onlyNegativeValues = false;
        public bool onlyPositiveValues = false;

        [Range(1,8)]
        public int numOctaves = 2;
        public float lacunarity = 2;
        public float persistance = 0.5f;
        public float noiseScale = 2.5f;
        public float noiseWeight = 5;
        public float weightMultiplier = 2.5f;

        [Range(0,1)]
        public float finalStrength = 1;

        public float floorOffset = 4f;
        public Vector3 center;
        public int seed = 0;

    }

    [System.Serializable]
    public class LevelNoiseSettings
    {
        public int NumChunksHeight = 1;

        public int yThreshold = 6;

        public float strength = 1;
    }

    [System.Serializable]
    public class Perlin2DNoiseSettings
    {

    }
}

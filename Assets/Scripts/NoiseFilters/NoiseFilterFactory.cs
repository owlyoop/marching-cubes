﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class NoiseFilterFactory
{
    public static INoiseFilter CreateNoiseFilter(NoiseSettings settings)
    {
        switch (settings.filterType)
        {
            case NoiseSettings.FilterType.Simplex:
                return new SimplexNoiseFilter(settings.simplexNoiseSettings);
            case NoiseSettings.FilterType.Ridged:
                return new RidgedNoiseFilter(settings.ridgedNoiseSettings);
            case NoiseSettings.FilterType.LevelTerrain:
                return new LevelNoiseFilter(settings.levelNoiseSettings);
        }
        return null;
    }

}

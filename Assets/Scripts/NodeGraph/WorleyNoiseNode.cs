using ProceduralNoiseProject;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

[CreateNodeMenu("NoiseGenerators/Worley")]
public class WorleyNoiseNode : NoiseGeneratorNode
{
    
    public WorleyNoise wnoise;

    public VORONOI_DISTANCE distance;
    public VORONOI_COMBINATION combination;

    public bool solidCells = false;

    public float jitter = 1;
    public float frequency = 0.1f;
    public float amplitude = 1;



	protected override void Init()
    {
        wnoise = new WorleyNoise(seed, frequency, jitter);
        wnoise.Distance = distance;
        wnoise.Combination = combination;
		base.Init();
	}

    public override float Evaluate(Vector3 point)
    {
        wnoise.Frequency = frequency;
        wnoise.Amplitude = amplitude;
        wnoise.Jitter = jitter;
        wnoise.Distance = distance;
        wnoise.Combination = combination;

        float noiseValue = 0;

        if (solidCells)
        {
            noiseValue = wnoise.Solid3D(point.x, point.y, point.z);
        }
        else
        {
            noiseValue = wnoise.Sample3D(point.x, point.y, point.z);
        }
        
        Mathf.Clamp(noiseValue, -1f, 1f);
        return noiseValue;
    }

    public override void RandomizeNoiseSeed(int seed)
    {
        if (wnoise != null)
            wnoise.UpdateSeed(seed);
    }

    // Return the correct value of an output port when requested
    public override object GetValue(NodePort port)
    {
        return Evaluate(worldGraph.noiseGenPoint);
    }
}
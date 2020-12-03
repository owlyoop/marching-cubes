using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XNode;

public class SimplexNoiseNode : Node
{
    public int seed = 0;
    public float strength = 1;
    [Range(1, 8)] public int numOctaves;
    public Vector3 noiseCenter;

    [Output] float point;

    Noise noise = new Noise();

    // Use this for initialization
    protected override void Init()
    {
		base.Init();
	}

    public void Evaluate(Vector3 point)
    {
        
    }

	// Return the correct value of an output port when requested
	public override object GetValue(NodePort port)
    {
		return null; // Replace this
	}
}
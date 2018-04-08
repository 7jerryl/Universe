using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InsideGpuPlanet : MonoBehaviour {

    private GameObject atmosphere;
    public Color atmosphereColor;
    // Use this for initialization
    void Awake () {
        atmosphere = new GameObject("Atmosphere");
        atmosphere.transform.position = new Vector3(transform.position.x, 5000, transform.position.z);
    }
	
	// Update is called once per frame
	void Update () {
        atmosphere.transform.position = new Vector3(transform.position.x, 5000, transform.position.z);
	}
}

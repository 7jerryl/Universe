using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwapLOD : MonoBehaviour {
    
    public float[] distances;
    public GameObject activeObject;
    private bool matReady = false, isNear = false;

    // Use this for initialization
    void Start () {
        activeObject = transform.GetChild(0).gameObject;
        activeObject.SetActive(true);
    }

    // Update is called once per frame
    void Update () {
        if (distances == null) return;

        int i = 0;

        MeshRenderer meshRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();

        Vector3
            playerPos = Camera.main.transform.parent.position,
            centerPos = transform.parent.position,
            meshPos = meshRenderer.bounds.ClosestPoint(playerPos);

        float playerDist = Vector3.Distance(playerPos, centerPos);
        
        for (; i < distances.Length; i++)
        {
            if (playerDist < distances[i])
            {
                break;
            }
        }

        Vector3
            playerNorm = (playerPos - centerPos).normalized;

        isNear = Vector3.Distance(playerPos, meshPos) < 1000f;

        i = (isNear ? Mathf.Max(0, distances.Length - (i + 1)) : 0);

        GameObject nextLOD = transform.GetChild(i).gameObject;

        if (!activeObject.Equals(nextLOD))
        {
            activeObject.SetActive(false);
            activeObject = nextLOD;
            activeObject.SetActive(true);
        }

        if (!matReady)
        {
            Material mat = GetComponentInParent<MeshRenderer>().material;
            matReady = mat.name.ToLower().Contains("planet");

            if (matReady)
            {
                for (int j = 0; j < transform.childCount; j++)
                {
                    transform.GetChild(j).GetComponent<MeshRenderer>().material = mat;
                }
            }
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageEffects : MonoBehaviour {

    public Color color = Color.black;
    public float distance = float.MaxValue;
    private Material material;

    // Creates a private material used to the effect
    void Awake()
    {
        material = new Material(Shader.Find("Hidden/MainEffects"));
    }

    // Postprocess the image
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetColor("_Color", color);
        material.SetFloat("_Distance", distance);
        Graphics.Blit(source, destination, material);
    }
}

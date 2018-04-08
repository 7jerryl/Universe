using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class gasGiant : MonoBehaviour {

    MeshRenderer meshRenderer;
    int width = 1024, height = 512;
    Color atmosphereCol = Color.black;
    // Use this for initialization
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();

        meshRenderer.material.SetVector("_Center", transform.position);

        Texture2D
            mainTex = GetRender(1),
            bumpMap = GetRender(0);

        atmosphereCol = GetColor(1).GetPixel(0, 0);

        meshRenderer.material = Resources.Load("Materials/gasGiantSurface") as Material;

        meshRenderer.material.SetTexture("_MainTex", mainTex);
        meshRenderer.material.SetTexture("_BumpMap", bumpMap);
        meshRenderer.material.SetTexture("_Detail", Resources.Load("Textures/CloudDetail") as Texture2D);

        meshRenderer.material.EnableKeyword("_NORMALMAP");

        meshRenderer.material.SetVector("_Center", transform.position);

        meshRenderer.material.SetVector("_Detail_ST", new Vector4(50, 50, 0, 0));

        Vector2
            pos = new Vector2(transform.position.x + transform.position.y, transform.position.z + transform.position.y);
        float
            clMovX = Mathf.PerlinNoise(pos.x * 0.822f + 0.3f, pos.y * 0.912f + 0.2f) / (3 * transform.localScale.magnitude),
            clMovY = Mathf.PerlinNoise(pos.x * 0.922f + 0.3f, pos.y * 0.822f + 0.1f) / (3 * transform.localScale.magnitude),
            p = Mathf.Sqrt(Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.401f + 0.3f, pos.y * 0.913f + 0.1f))) * 2.5f + 0.5f;

        meshRenderer.material.SetFloat("_RimPower", p);
        meshRenderer.material.SetVector("_CloudMovement", new Vector2(clMovX, clMovY));
    }

    // Update is called once per frame
    void Update()
    {
        if (Vector3.Distance(transform.position, Camera.main.transform.position) < transform.localScale.x * 0.505f)
        {
            ImageEffects imageEffects = Camera.main.GetComponent<ImageEffects>();
            imageEffects.color = atmosphereCol;
        }
    }

    Texture2D GetRender(int pass)
    {
        Texture2D tex = new Texture2D(width, height, TextureFormat.ARGB32, false);
        meshRenderer.material.SetTexture("_MainTex", tex);
        RenderTexture renderTexture = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        Graphics.Blit(tex, renderTexture, meshRenderer.material, pass);
        RenderTexture.active = renderTexture;
        tex.ReadPixels(new Rect(0, 0, width, height), 0, 0, false);
        tex.Apply();

        return tex;
    }

    Texture2D GetColor(int pass)
    {
        Texture2D tex = new Texture2D(1, 1, TextureFormat.ARGB32, false);
        meshRenderer.material.SetTexture("_MainTex", tex);
        RenderTexture renderTexture = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        Graphics.Blit(tex, renderTexture, meshRenderer.material, pass);
        RenderTexture.active = renderTexture;
        tex.ReadPixels(new Rect(Random.Range(0, width - 1), Random.Range(0, height - 1), width, height), 0, 0, false);
        tex.Apply();

        return tex;
    }
}

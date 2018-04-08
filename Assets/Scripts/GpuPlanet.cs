using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class GpuPlanet : MonoBehaviour {

    public float radius = 1000f;
    public Texture2D mainTex, bumpMap, clouds;
    private MeshRenderer meshRenderer;
    private int width = 1024, height = 512;
    private Color atmosphereCol = Color.black, cloudCol = Color.black;
    private float gravity = 0f, prevDistance = Mathf.Infinity;
    private new Light light;
    private Movement m;
    private ImageEffects imeffects;
    // Use this for initialization

    void Start ()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        meshRenderer.material = Resources.Load("Materials/gpuPlanet") as Material;

        meshRenderer.material.SetVector("_Center", transform.position);

        mainTex = GetRender(2);
        bumpMap = GetRender(1);
        clouds = GetRender(0);

        meshRenderer.material = Resources.Load("Materials/planetSurface") as Material;

        meshRenderer.material.SetTexture("_MainTex", mainTex);
        meshRenderer.material.SetTexture("_Detail", Resources.Load("Textures/LandDetail") as Texture2D);
        meshRenderer.material.SetTexture("_Detail2", Resources.Load("Textures/WaterDetail") as Texture2D);
        meshRenderer.material.SetTexture("_Detail3", Resources.Load("Textures/CloudDetail") as Texture2D);
        meshRenderer.material.SetTexture("_Detail4", Resources.Load("Textures/LandDetail2") as Texture2D);
        meshRenderer.material.SetTexture("_BumpMap", bumpMap);
        meshRenderer.material.SetTexture("_Clouds", clouds);

        meshRenderer.material.SetVector("_Center", transform.position);

        meshRenderer.material.EnableKeyword("_NORMALMAP");

        Vector2
            pos = new Vector2(transform.position.x + transform.position.y, transform.position.z + transform.position.y);
        float
            r1 = Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.452f + 0.3f, pos.y * 0.452f + 0.281f)),
            g1 = Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.132f + 0.1f, pos.y * 0.132f + 0.399f)),
            b1 = Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.822f + 0.3f, pos.y * 0.822f + 0.125f)),
            r2 = Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.252f + 0.3f, pos.y * 0.452f + 0.290f)),
            g2 = Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.632f + 0.1f, pos.y * 0.332f + 0.383f)),
            b2 = Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.922f + 0.3f, pos.y * 0.322f + 0.183f)),
            clMovX = Mathf.PerlinNoise(pos.x * 0.822f + 0.3f, pos.y * 0.912f + 0.2f) / (2 * 500f),
            clMovY = Mathf.PerlinNoise(pos.x * 0.922f + 0.3f, pos.y * 0.822f + 0.1f) / (2 * 500f),
            p = Mathf.Sqrt(Mathf.Abs(Mathf.PerlinNoise(pos.x * 0.401f + 0.3f, pos.y * 0.913f + 0.1f))) * 2.5f + 0.5f;

        gravity = p;

        Vector3 rimColor = 1.5f * Vector3.Normalize(new Vector3(r1, g1, b1));
        Vector3 cloudColor = 1.5f * Vector3.Normalize(new Vector3(r2, g2, b2));

        atmosphereCol = new Color(rimColor.x, rimColor.y, rimColor.z);
        cloudCol = new Color(cloudColor.x, cloudColor.y, cloudColor.z);

        meshRenderer.material.SetVector("_RimColor", rimColor);
        meshRenderer.material.SetFloat("_RimPower", p);
        meshRenderer.material.SetVector("_CloudColor", cloudCol);
        meshRenderer.material.SetVector("_CloudMovement", new Vector2(clMovX, clMovY));

        light = Light.GetLights(LightType.Directional, 0)[0];
        meshRenderer.material.SetVector("_Star", light.transform.position);

        m = Camera.main.gameObject.GetComponentInParent<Movement>();
        imeffects = Camera.main.GetComponent<ImageEffects>();
    }

    // Update is called once per frame
    void Update()
    {
        float distance = Mathf.Clamp01((Vector3.Distance(transform.position, Camera.main.transform.position) - radius * 1.04f) / (radius * 0.04f));
        if (distance < 1.0f || (prevDistance < 1.0f && m.planet.Equals(gameObject)))
        {
            if (distance < 0.5f)
            {
                Transform playerT = Camera.main.transform.parent;
                
                playerT.rotation = Quaternion.RotateTowards(
                    playerT.rotation,
                    Quaternion.FromToRotation(
                    playerT.up,
                    Vector3.Normalize(playerT.position - transform.position))
                    * playerT.rotation,
                    0.15f * Mathf.PI);
            }
            
            Vector3 normalDir = Vector3.Normalize(Camera.main.transform.parent.position - transform.position),
                lightDir = Vector3.Normalize(light.transform.forward);
            float angle = Vector3.Angle(normalDir, lightDir),
                normAngle = Mathf.Pow(Mathf.Clamp01((180 - angle) / 85), 2);

            meshRenderer.material.SetFloat("_Distance", distance);

            float skyValue = (1 - (1 - distance) * (1 - normAngle));

            Camera.main.backgroundColor = (skyValue) * Color.black + (1 - skyValue) * atmosphereCol;
            imeffects.distance = skyValue;
            imeffects.color = atmosphereCol;

            if (distance < 1.0f)
            {
                if (m.planet == null)
                    m.planet = gameObject;
            }
            else
            {
                if (m.planet != null)
                    m.planet = null;
            }
            prevDistance = distance;
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
}

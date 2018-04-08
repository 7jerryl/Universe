using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereLOD : MonoBehaviour {

    public float planetRadius = 10000f;
    private Texture2D mainTex, bumpMap, clouds;

    Vector3[] dir =
    {
        Vector3.up,
        Vector3.forward,
        Vector3.right,
        Vector3.down,
        Vector3.back,
        Vector3.left
    };

    Quaternion[] rot =
    {
        Quaternion.LookRotation(Vector3.forward),
        Quaternion.LookRotation(Vector3.down),
        Quaternion.LookRotation(Vector3.forward, Vector3.right),
        Quaternion.LookRotation(Vector3.forward, Vector3.down),
        Quaternion.LookRotation(Vector3.up),
        Quaternion.LookRotation(Vector3.forward, Vector3.left)
    };

	// Use this for initialization
	void Start ()
    {
        gameObject.AddComponent<GpuPlanet>().radius = planetRadius;
    }

    // Update is called once per frame
    void Update ()
    {
        if (mainTex == null)
        {
            mainTex = gameObject.GetComponent<GpuPlanet>().mainTex;
            CreateCube(planetRadius * 2, 5, new float[] { planetRadius * 1.04f, planetRadius * 1.07f, planetRadius * 1.1f });
        }
    }

    void CreateCube(float size, int res, float[] distances, int subdiv = 2)
    {
        for (int i = 0; i < dir.Length; i++)
        {
            for (int k = 0; k < subdiv * subdiv; k++)
            {
                GameObject lodSwapper = new GameObject("LOD Swap");
                lodSwapper.transform.rotation = rot[i];
                lodSwapper.transform.position = transform.position + dir[i] * size / 2;

                gameObject.transform.position = transform.position;

                for (int j = 0; j < distances.Length; j++)
                {
                    GameObject surface = new GameObject("LOD" + j.ToString());

                    surface.AddComponent<MeshFilter>().mesh = CreatePlane(
                        dir[i] * size / 2,
                        subdiv,
                        k,
                        size, size,
                        res * (int) Mathf.Pow(2, j * 2.5f),
                        res * (int) Mathf.Pow(2, j * 2.5f));
                    surface.AddComponent<MeshRenderer>();
                    surface.AddComponent<MeshCollider>();

                    surface.transform.position = transform.position;

                    surface.SetActive(false);

                    surface.transform.SetParent(lodSwapper.transform);
                }

                lodSwapper.transform.SetParent(transform);
                SwapLOD swapLOD = lodSwapper.AddComponent<SwapLOD>();
                swapLOD.distances = distances;
            }
        }
    }

    Mesh CreatePlane(Vector3 direction, int subdiv, int k, float length = 1f, float width = 1f, int resX = 2, int resZ = 2)
    {
        // You can change that line to provide another MeshFilter
        Mesh mesh = new Mesh();

        resX++;
        resZ++;

        #region Vertices		
        List<Vector3> vertices = new List<Vector3>(new Vector3[resX * resZ]);
        Vector3 normDir = Vector3.Normalize(direction);
        for (int z = 0; z < resZ; z++)
        {
            // [ -length / 2, length / 2 ]
            float zPos = ((float)z / (resZ - 1) + (k % subdiv) - (subdiv / 2)) * length / subdiv;
            for (int x = 0; x < resX; x++)
            {
                // [ -width / 2, width / 2 ]
                float xPos = ((float)x / (resX - 1) + (k / subdiv) - (subdiv / 2)) * width / subdiv;

                Vector3 v = Quaternion.FromToRotation(Vector3.up, normDir)
                    * new Vector3(xPos, 0f, zPos) + direction;

                vertices[x + z * resX] = v.normalized * length / 2;
            }
        }
        #endregion

        #region Normals_Tangents
        List<Vector3> normals = new List<Vector3>(new Vector3[vertices.Count]);
        List<Vector4> tangents = new List<Vector4>(new Vector4[vertices.Count]);
        for (int n = 0; n < normals.Count; n++)
        {
            normals[n] = vertices[n].normalized;
            Vector3 tangent = Vector3.Cross(normals[n], Vector3.forward);

            if (tangent.magnitude == 0)
            {
                tangent = Vector3.Cross(normals[n], Vector3.up);
            }

            tangents[n] = new Vector4(tangent.x, tangent.y, tangent.z, 1);
        }
        #endregion

        #region UVs		
        List<Vector2> uvs = new List<Vector2>(new Vector2[vertices.Count]);
        for (int v = 0; v < resZ; v++)
        {
            for (int u = 0; u < resX; u++)
            {
                // uvs[u + v * resX] = new Vector2((float)u / (resX - 1), (float)v / (resZ - 1));

                Vector3 n = normals[u + v * resX];
                Vector2 uv = new Vector2(Mathf.Atan2(n.x, n.z) / (2f * Mathf.PI) + 0.5f, n.y * 0.5f + 0.5f);

                //vertices[u + v * resX] = new Vector3(uv.x, 0, uv.y);
                float center = mainTex.GetPixel((int)(uv.x * mainTex.width), (int)(uv.y * mainTex.height)).a;
                /*
                float
                    center = mainTex.GetPixel((int)(uv.x * mainTex.width), (int)(uv.y * mainTex.height)).a,
                    left = mainTex.GetPixel((int)(uv.x * mainTex.width - 1), (int)(uv.y * mainTex.height)).a,
                    right = mainTex.GetPixel((int)(uv.x * mainTex.width + 1), (int)(uv.y * mainTex.height)).a,
                    top = mainTex.GetPixel((int)(uv.x * mainTex.width), (int)(uv.y * mainTex.height - 1)).a,
                    bottom = mainTex.GetPixel((int)(uv.x * mainTex.width), (int)(uv.y * mainTex.height + 1)).a,
                    tl = mainTex.GetPixel((int)(uv.x * mainTex.width - 1), (int)(uv.y * mainTex.height - 1)).a,
                    tr = mainTex.GetPixel((int)(uv.x * mainTex.width + 1), (int)(uv.y * mainTex.height - 1)).a,
                    bl = mainTex.GetPixel((int)(uv.x * mainTex.width - 1), (int)(uv.y * mainTex.height + 1)).a,
                    br = mainTex.GetPixel((int)(uv.x * mainTex.width + 1), (int)(uv.y * mainTex.height + 1)).a;
                */
                uvs[u + v * resX] = uv;
                //if (center < 0.4f)
                    //vertices[u + v * resX] += n * 200f * Mathf.PerlinNoise(uv.x * 150f, uv.y * 75f) * Mathf.Pow(0.4f - center, 2);
                /*
                if (center < 0.4f && left < 0.4f && right < 0.4f && top < 0.4f && bottom < 0.4f && tl < 0.4f && tr < 0.4f && bl < 0.4f && br < 0.4f)
                {
                    vertices[u + v * resX] += n * 200f * Mathf.PerlinNoise(uv.x * 150f, uv.y * 75f) * (0.4f - center);// n * 75f * Mathf.PerlinNoise(uv.x * 75f, uv.y * 75f) * (0.4f - center);
                }
                */
            }
        }
        #endregion

        #region Triangles
        int nbFaces = (resX - 1) * (resZ - 1);
        List<int> triangles = new List<int>(new int[nbFaces * 6]);
        int t = 0;
        for (int face = 0; face < nbFaces; face++)
        {
            // Retrieve lower left corner from face ind
            int i = face % (resX - 1) + (face / (resZ - 1) * resX);
            int T = t;

            triangles[t++] = i + resX;
            triangles[t++] = i + 1;
            triangles[t++] = i;

            triangles[t++] = i + resX;
            triangles[t++] = i + resX + 1;
            triangles[t++] = i + 1;
            
            for (; T < t; T++)
            {
                if (uvs[triangles[T]].x == 1f)
                {
                    Vector2 uv = uvs[triangles[T]];
                    uv.x = 0;

                    if (T < t - 3)
                    {
                        if (uvs[triangles[t - 6]].x < 0.5 || uvs[triangles[t - 5]].x < 0.5 || uvs[triangles[t - 4]].x < 0.5)
                            uvs[triangles[T]] = uv;
                    }
                    else
                    {
                        if (uvs[triangles[t - 3]].x < 0.5 || uvs[triangles[t - 2]].x < 0.5 || uvs[triangles[t - 1]].x < 0.5)
                            uvs[triangles[T]] = uv;
                    }
                }
            }
        }
        #endregion

        mesh.vertices = vertices.ToArray();
        mesh.normals = normals.ToArray();
        mesh.uv = uvs.ToArray();
        mesh.triangles = triangles.ToArray();
        mesh.tangents = tangents.ToArray();

        mesh.RecalculateBounds();
        return mesh;
    }
}

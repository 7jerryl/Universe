using UnityEngine;
using UnityEngine.UI;

public class Movement : MonoBehaviour
{
    public float movementSpeed = 200f, rotationSpeed = 3f, gravity = 150f; 
    public GameObject planet;
    private Vector3 pos;
    private Canvas canvas;
    private Transform body;

    private void Start()
    {
        pos = transform.position;
        canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        body = transform.Find("Body");
    }

    void FixedUpdate()
    {
        movementSpeed = Mathf.Max(movementSpeed + 10f * (Input.GetButton("Flying Boost") ? 1f : -1f), 200f);

        float step = movementSpeed * Time.deltaTime,
            gravityStep = gravity * Time.deltaTime;

        transform.Rotate(new Vector3(-Input.GetAxis("Mouse Y"), Input.GetAxis("Mouse X"), 0) * rotationSpeed);
        body.rotation = Camera.main.transform.rotation;

        if (Input.GetAxis("Horizontal") != 0.0f || Input.GetAxis("Vertical") != 0.0f)
        {
            pos = Vector3.MoveTowards(transform.position,
                transform.position + (body.right * Input.GetAxis("Horizontal") + body.forward * Input.GetAxis("Vertical")
                    + body.up * Input.GetAxis("Depth")) * movementSpeed,
                step);
        }

        if (planet != null)
        {

            int layerMask = 1 << 8;
            layerMask = ~layerMask;

            RaycastHit hit;
            Vector3 n = Vector3.Normalize(planet.transform.position - pos);
            Physics.Raycast(pos - n * 200.0f, n, out hit, Mathf.Infinity, layerMask);

            if (hit.collider != null)
            {
                pos = Vector3.MoveTowards(pos, hit.point - n * 20f, gravityStep);
            }

            if (Vector3.Distance(pos, planet.transform.position) < Vector3.Distance(hit.point - n * 20f, planet.transform.position))// || Vector3.Angle(pos - hit.point - n * 20f, n) < 90.0f)
            {
                pos = hit.point - n * 20f;
            }
        }

        transform.position = pos;
    }
}
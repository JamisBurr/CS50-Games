using UnityEngine;

public class ProjectileBehavior : MonoBehaviour
{
    public GameObject hitPrefab;  // The prefab to instantiate when hitting a target or any object.
    private Rigidbody rb;
    private float lifetime = 5.0f;  // Lifetime of the projectile until self-destruct.

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        if (rb == null) {
            rb = gameObject.AddComponent<Rigidbody>();  // Ensure Rigidbody is present.
        }
        rb.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
        rb.useGravity = false;  // Projectiles typically do not use gravity.
        Invoke(nameof(DestroyProjectile), lifetime);  // Schedule the projectile to be destroyed after 5 seconds.
    }

    public void Initialize(float speed)
    {
        rb.velocity = transform.forward * speed;
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player")) // Check if it hits the player
        {
            HandleCollision(collision.contacts[0].point, collision.contacts[0].normal, "Player");
        }
        else if (collision.gameObject.CompareTag("Enemy")) // Check if it hits an enemy
        {
            HandleCollision(collision.contacts[0].point, collision.contacts[0].normal, "Enemy");
        }
        else
        {
            // Reflect the projectile if it doesn't hit the player or enemy
            ReflectProjectile(collision.contacts[0].normal);
        }
    }

    private void HandleCollision(Vector3 collisionPoint, Vector3 collisionNormal, string targetType)
    {
        if (hitPrefab != null)
        {
            Quaternion rot = Quaternion.FromToRotation(Vector3.up, collisionNormal);
            Vector3 pos = collisionPoint + collisionNormal * 0.1f;  // Offset slightly to prevent clipping.
            var hitVFX = Instantiate(hitPrefab, pos, rot);
            Destroy(hitVFX, 2f);  // Destroy after 2 seconds.
        }

        if (targetType == "Player")
        {
            Collider[] hitColliders = Physics.OverlapSphere(collisionPoint, 0.5f);  // Small radius to detect the player
            foreach (var hitCollider in hitColliders)
            {
                if (hitCollider.gameObject.CompareTag("Player"))
                {
                    hitCollider.GetComponent<PlayerController>().Die();
                }
            }
        }
        else if (targetType == "Enemy")
        {
            Collider[] hitColliders = Physics.OverlapSphere(collisionPoint, 0.5f);  // Small radius to detect the enemy
            foreach (var hitCollider in hitColliders)
            {
                if (hitCollider.gameObject.CompareTag("Enemy"))
                {
                    hitCollider.GetComponent<EnemyAI>().Die();
                }
            }
        }

        Destroy(gameObject);  // Destroy the projectile after hitting the target.
    }

    private void ReflectProjectile(Vector3 normal)
    {
        rb.velocity = Vector3.Reflect(rb.velocity, normal);
    }

    private void DestroyProjectile()
    {
        // Destroy the projectile after 5 seconds if it hasn't collided with a target.
        if (gameObject != null)
        {
            Destroy(gameObject);
        }
    }
}

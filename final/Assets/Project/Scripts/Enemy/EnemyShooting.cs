using UnityEngine;

public class EnemyShooting : MonoBehaviour
{
    public GameObject bulletPrefab; // Prefab for the bullets
    public Transform firePoint; // Point from which bullets are fired
    public float bulletSpeed = 10f; // Speed of the bullets
    public AudioSource gunshotAudioSource; // Audio source for gunshot sound
    public AudioClip gunshotSound; // Audio clip for gunshot sound
    public GameObject muzzleFlashPrefab; // Muzzle flash prefab
    public float shootCooldown = 1.0f; // Time between shots
    [HideInInspector] public float shootTimer = 0f; // Timer for cooldown, hidden in inspector

    void Start()
    {
        // Initialize the shoot timer to the cooldown to prevent immediate shooting
        shootTimer = shootCooldown;
    }

    void Update()
    {
        if (shootTimer > 0f)
        {
            shootTimer -= Time.deltaTime; // Decrease the shoot timer
        }
    }

    public void Shoot()
    {
        if (shootTimer <= 0f) // Ensure cooldown has passed
        {
            // Play gunshot sound and show muzzle flash
            if (gunshotAudioSource != null && gunshotSound != null)
            {
                gunshotAudioSource.PlayOneShot(gunshotSound);
            }

            if (muzzleFlashPrefab != null)
            {
                GameObject muzzleFlash = Instantiate(muzzleFlashPrefab, firePoint.position, firePoint.rotation);
                Destroy(muzzleFlash, 0.5f); // Destroy the flash after a short time
            }

            // Create and shoot a bullet
            if (bulletPrefab != null)
            {
                GameObject bullet = Instantiate(bulletPrefab, firePoint.position, Quaternion.identity);
                Rigidbody bulletRigidbody = bullet.GetComponent<Rigidbody>();
                bulletRigidbody.velocity = firePoint.forward * bulletSpeed;
                Destroy(bullet, 3f); // Destroy the bullet after 3 seconds
            }

            shootTimer = shootCooldown; // Reset the shoot timer
        }
    }
}

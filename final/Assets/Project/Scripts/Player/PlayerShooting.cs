using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerShooting : MonoBehaviour
{
    public GameObject bulletPrefab;
    public Transform firePoint;
    public float bulletSpeed = 10f;
    public float shootCooldown = 0.5f;
    private float shootTimer = 0f;
    private bool isAiming = false;

    private Animator animator; // Reference to the Animator component
    
    public LayerMask wallLayerMask; // Layer mask to filter out wall collisions

    // Reference to the existing AudioSource on the AssaultRifle
    public AudioSource gunshotAudioSource;

    // Public field for the gun firing audio clip
    public AudioClip gunshotSound;

    // New public field for the muzzle flash prefab
    public GameObject muzzleFlashPrefab; // Reference to the muzzle flash prefab

    void Start()
    {
        animator = GetComponentInParent<Animator>();
        
        // Ensure the AudioSource is referenced
        if (gunshotAudioSource == null)
        {
            Debug.LogError("Gunshot AudioSource is missing. Please assign it in the Unity Editor.");
        }

        // Ensure the muzzle flash prefab is set
        if (muzzleFlashPrefab == null)
        {
            Debug.LogError("Muzzle flash prefab is missing. Please assign it in the Unity Editor.");
        }
    }

    public void OnFire(InputAction.CallbackContext context)
    {
        if (isAiming && context.started && shootTimer <= 0f)
        {
            Shoot(); // Perform shooting
            shootTimer = shootCooldown; // Reset cooldown timer

            // Trigger the shooting animation
            if (animator != null)
            {
                animator.SetTrigger("Fire");
            }
        }
    }

    void Update()
    {
        if (shootTimer > 0f)
        {
            shootTimer -= Time.deltaTime;
        }
    }

    void Shoot()
    {
        // Ensure the AudioSource has a constant pitch
        if (gunshotAudioSource != null)
        {
            gunshotAudioSource.pitch = 1.0f; // Set pitch to default
            gunshotAudioSource.PlayOneShot(gunshotSound); // Play the gunshot sound
        }

        // Instantiate the muzzle flash at the firing point
        if (muzzleFlashPrefab != null)
        {
            GameObject muzzleFlash = Instantiate(muzzleFlashPrefab, firePoint.position, firePoint.rotation);
            Destroy(muzzleFlash, 0.5f); // Destroy the muzzle flash after a short delay
        }
        
        // Additional shooting logic
        GameObject bullet = Instantiate(bulletPrefab, firePoint.position, Quaternion.identity);
        Rigidbody bulletRigidbody = bullet.GetComponent<Rigidbody>();
        bulletRigidbody.velocity = firePoint.forward.normalized * bulletSpeed;

        Destroy(bullet, 3f); // Destroy the bullet after 3 seconds
    }

    public void SetAiming(bool aiming)
    {
        isAiming = aiming;
    }
}

using UnityEngine;
using UnityEngine.AI;
using System.Collections;

public class EnemyAI : MonoBehaviour
{
    public Transform player; // The target to follow
    public GameObject deathVFXPrefab;
    public AudioClip hitSFX; // The sound effect to play when hit
    public float detectionRange = 20f; // Detection range to start following the player
    public float stoppingDistance = 2f; // Distance to stop when near the player
    public float engagementRange = 10f; // Range to engage and start aiming

    private Animator animator; // Reference to the Animator component
    private NavMeshAgent navMeshAgent; // The NavMeshAgent component
    private bool isInvincible; // Flag to check invincibility
    private EnemyShooting enemyShooting; // Reference to EnemyShooting component
    private AudioSource audioSource; // Reference to the AudioSource component
    private float shootTimer; // Timer for shooting

    void Start()
    {
        animator = GetComponent<Animator>(); // Initialize the Animator
        navMeshAgent = GetComponent<NavMeshAgent>(); // Initialize the NavMeshAgent
        navMeshAgent.enabled = true;
        navMeshAgent.stoppingDistance = stoppingDistance; // Set stopping distance

        audioSource = GetComponent<AudioSource>(); // Initialize the AudioSource

        // Automatically find and assign the player if not set
        if (player == null)
        {
            GameObject playerObj = GameObject.FindGameObjectWithTag("Player");
            if (playerObj != null)
            {
                player = playerObj.transform;
            }
            else
            {
                Debug.LogError("Player object not found! Make sure the player is tagged correctly.");
            }
        }

        enemyShooting = GetComponent<EnemyShooting>(); // Get the EnemyShooting component
        enemyShooting.shootTimer = enemyShooting.shootCooldown; // Initialize shoot timer to prevent immediate shooting

        StartCoroutine(InvincibilityTimer());
    }

    IEnumerator InvincibilityTimer()
    {
        isInvincible = true; // Enemy becomes invincible
        yield return new WaitForSeconds(0.5f); // Invincible for 0.5 seconds
        isInvincible = false; // Enemy is no longer invincible
    }

    void Update()
    {
        if (player == null)
        {
            return; // Early exit if no player is found
        }

        float distanceToPlayer = Vector3.Distance(transform.position, player.position);

        if (distanceToPlayer < detectionRange) // If player is within detection range
        {
            if (distanceToPlayer > stoppingDistance) // If outside stopping distance
            {
                navMeshAgent.destination = player.position; // Move toward the player
                navMeshAgent.updatePosition = true; // Allow position updates
                
                // Determine whether the enemy should aim
                bool isAiming = distanceToPlayer < engagementRange;
                animator.SetBool("isAiming", isAiming);

                // Determine if the enemy is moving
                bool isMoving = navMeshAgent.velocity.magnitude > 0.1f;
                animator.SetBool("isRunning", isMoving);

                // Update MoveX and MoveZ based on movement direction
                Vector3 direction = (player.position - transform.position).normalized;
                animator.SetFloat("MoveX", direction.x);
                animator.SetFloat("MoveZ", direction.z);

                // Handle shooting
                if (isAiming && enemyShooting.shootTimer <= 0f)
                {
                    enemyShooting.Shoot();
                    enemyShooting.shootTimer = enemyShooting.shootCooldown; // Reset the shoot timer
                }
            }
            else // If within stopping distance
            {
                navMeshAgent.destination = transform.position; // Stop moving
                navMeshAgent.updatePosition = false; // Prevent position updates
                navMeshAgent.updateRotation = true; // Allow rotation towards player

                // Set animations
                animator.SetBool("isRunning", false);
                animator.SetBool("isAiming", true);
                animator.SetFloat("MoveX", 0);
                animator.SetFloat("MoveZ", 0);

                // Rotate towards the player
                RotateTowardsPlayer(); // New method for rotation

                // Handle shooting
                if (enemyShooting.shootTimer <= 0f)
                {
                    enemyShooting.Shoot();
                    enemyShooting.shootTimer = enemyShooting.shootCooldown; // Reset the shoot timer
                }
            }
        }
        else
        {
            // If outside detection range, reset the animations and NavMeshAgent
            navMeshAgent.destination = transform.position;
            navMeshAgent.updatePosition = false; // Stop movement
            navMeshAgent.updateRotation = false; // Stop rotation
            animator.SetBool("isRunning", false);
            animator.SetBool("isAiming", false);
        }

        // Update shoot timer
        if (enemyShooting.shootTimer > 0f)
        {
            enemyShooting.shootTimer -= Time.deltaTime;
        }
    }

    // New method to rotate towards the player
    void RotateTowardsPlayer()
    {
        if (player != null)
        {
            Vector3 direction = (player.position - transform.position).normalized;
            Quaternion lookRotation = Quaternion.LookRotation(direction);
            transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 5f); // Smooth rotation
        }
    }

    public void Die()
    {
        if (isInvincible) return;

        animator.SetTrigger("Die");  // Trigger the die animation
        if (navMeshAgent != null)
        {
            navMeshAgent.enabled = false;
        }

        Collider[] colliders = GetComponentsInChildren<Collider>();
        foreach (Collider collider in colliders)
        {
            collider.enabled = false;
        }

        enabled = false;  // Stop the Update method

        StartCoroutine(StartDissolveEffect());
    }

    IEnumerator StartDissolveEffect()
    {
        // Delay before starting the VFX
        yield return new WaitForSeconds(2);

        // Instantiate death VFX
        if (deathVFXPrefab != null)
        {
            GameObject vfx = Instantiate(deathVFXPrefab, transform.position, transform.rotation); // Use the enemy's rotation
            // Adjust the VFX position if needed
            vfx.transform.position += new Vector3(0, 0.5f, 0); // Adjust the offset if required
            Destroy(vfx, 5f); // Assuming the VFX should last for 5 seconds before being destroyed
        }

        // Destroy the enemy GameObject
        Destroy(gameObject);
    }

    // Method to handle getting hit by a projectile
    public void OnHit()
    {
        // Play the hit sound effect
        if (hitSFX != null && audioSource != null)
        {
            audioSource.PlayOneShot(hitSFX);
        }
    }
}

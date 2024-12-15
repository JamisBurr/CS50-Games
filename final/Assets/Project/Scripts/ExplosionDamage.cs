using UnityEngine;
using System.Collections;

// Attach this script to your VFXGraph_OrbExplosion prefab
public class ExplosionDamage : MonoBehaviour
{
    private Collider damageCollider;

    void Awake()
    {
        damageCollider = GetComponent<Collider>();
        damageCollider.enabled = false; // Initially disabled
        StartCoroutine(EnableDamageWindow());
    }

    IEnumerator EnableDamageWindow()
    {
        yield return new WaitForSeconds(3f); // Wait until the orb "hits" the ground
        damageCollider.enabled = true;
        yield return new WaitForSeconds(0.25f); // Damage window duration
        damageCollider.enabled = false;
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<PlayerController>().Die();
        }
    }
}

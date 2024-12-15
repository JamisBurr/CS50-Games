using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawner : MonoBehaviour
{
    public GameObject enemyPrefab; // The enemy prefab to spawn
    public GameObject vfxPrefab; // VFX prefab to play on spawn
    public float initialSpawnInterval = 5f; // Initial interval between spawns
    public float minimumSpawnInterval = 1f; // Minimum interval to cap the spawn speed
    public float spawnIntervalDecrement = 0.01f; // Amount by which the spawn interval decreases
    public Transform player; // Reference to the player's transform

    private GameObject[] spawnLocations;
    private float currentSpawnInterval;

    void Start()
    {
        spawnLocations = GameObject.FindGameObjectsWithTag("SpawnLocation");
        currentSpawnInterval = initialSpawnInterval; // Initialize the current spawn interval
        StartCoroutine(SpawnEnemies());
    }

    IEnumerator SpawnEnemies()
    {
        while (true)
        {
            yield return new WaitForSeconds(currentSpawnInterval);

            int spawnIndex = Random.Range(0, spawnLocations.Length);
            GameObject spawnLocation = spawnLocations[spawnIndex];

            // Calculate the direction to the player
            Vector3 directionToPlayer = (player.position - spawnLocation.transform.position).normalized;
            directionToPlayer.y = 0; // Keep the direction strictly horizontal
            Quaternion lookRotation = Quaternion.LookRotation(directionToPlayer);

            // Instantiate VFX facing the player
            Instantiate(vfxPrefab, spawnLocation.transform.position, lookRotation);

            // Wait for the VFX to finish playing, assuming it takes 1.9 seconds
            yield return new WaitForSeconds(1.9f);

            // Instantiate the enemy with the adjusted rotation
            GameObject newEnemy = Instantiate(enemyPrefab, spawnLocation.transform.position, lookRotation);

            // Decrease the spawn interval, but do not go below the minimum spawn interval
            currentSpawnInterval = Mathf.Max(minimumSpawnInterval, currentSpawnInterval - spawnIntervalDecrement);
        }
    }
}

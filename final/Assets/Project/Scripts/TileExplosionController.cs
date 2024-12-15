using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class TileExplosionController : MonoBehaviour
{
    public GameObject[] tiles; // Array to hold the tile references
    public GameObject explosionVFXPrefab; // Assign the explosion VFX prefab here
    public float delayBetweenExplosions = 0.5f; // Delay between each tile's explosion
    public bool enableExplosions = true; // Control for enabling/disabling explosions
    public int minSafeSpots = 2; // Minimum number of safe spots
    public int maxSafeSpots = 4; // Maximum number of safe spots
    public int minTilesPerExplosion = 1; // Minimum number of tiles to explode at once
    public int maxTilesPerExplosion = 14; // Maximum number of tiles to explode at once
    
    void Start()
    {
        StartCoroutine(RandomExplosionPatterns());
    }


    IEnumerator RandomExplosionPatterns()
    {
        while (enableExplosions)
        {
            yield return StartCoroutine(ActivateRandomExplosions());
            yield return new WaitForSeconds(1f); // Reduced wait time before starting the next cycle
        }
    }

    IEnumerator ActivateRandomExplosions()
    {
        List<int> tileIndices = new List<int>();
        for (int i = 0; i < tiles.Length; i++)
        {
            tileIndices.Add(i);
        }

        // Shuffle the list
        for (int i = 0; i < tileIndices.Count; i++)
        {
            int randomIndex = Random.Range(0, tileIndices.Count);
            int temp = tileIndices[i];
            tileIndices[i] = tileIndices[randomIndex];
            tileIndices[randomIndex] = temp;
        }

        // Determine the number of safe spots
        int safeSpots = Random.Range(minSafeSpots, maxSafeSpots + 1);
        tileIndices.RemoveRange(0, safeSpots); // Remove indices for safe spots

        while (tileIndices.Count > 0)
        {
            // Determine the number of tiles to explode at once
            int tilesToExplode = Random.Range(minTilesPerExplosion, maxTilesPerExplosion + 1);
            tilesToExplode = Mathf.Min(tilesToExplode, tileIndices.Count); // Ensure we don't exceed remaining tiles

            List<int> currentExplosions = tileIndices.GetRange(0, tilesToExplode);
            tileIndices.RemoveRange(0, tilesToExplode);

            foreach (int index in currentExplosions)
            {
                StartCoroutine(ActivateExplosion(tiles[index].transform.position));
            }

            yield return new WaitForSeconds(delayBetweenExplosions);
        }
    }

    IEnumerator ActivateExplosion(Vector3 position)
    {
        yield return new WaitForSeconds(2f); // Reduced initial delay before explosion effect

        GameObject vfx = null;
        if (explosionVFXPrefab != null)
        {
            vfx = Instantiate(explosionVFXPrefab, position, Quaternion.identity);
        }

        yield return new WaitForSeconds(0.5f); // Wait for the visual effect, during which damage can be dealt

        if (vfx != null)
        {
            Destroy(vfx, 5f); // Cleanup VFX after 6 seconds, allowing for the visual effects to complete
        }
    }
}

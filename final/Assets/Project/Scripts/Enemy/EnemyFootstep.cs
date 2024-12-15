using UnityEngine;

public class EnemyFootstep : MonoBehaviour
{
    public AudioClip leftFootstepSound; // Footstep sound for the left foot
    public AudioClip rightFootstepSound; // Footstep sound for the right foot
    public AudioSource audioSource; // Audio source for footstep sounds
    
    [Range(0.1f, 3.0f)]
    public float footstepPitch = 1.0f; // Default pitch for footstep sounds

    public void FootstepEvent(int whichFoot)
    {
        // Stop any currently playing audio
        if (audioSource.isPlaying)
        {
            audioSource.Stop();
        }

        // Play the appropriate footstep sound
        if (whichFoot == 0)
        {
            audioSource.clip = leftFootstepSound;
        }
        else if (whichFoot == 1)
        {
            audioSource.clip = rightFootstepSound;
        }

        audioSource.pitch = footstepPitch; // Set the pitch
        audioSource.Play(); // Play the footstep sound
    }

    public void StopFootstepSound()
    {
        if (audioSource.isPlaying)
        {
            audioSource.Stop(); // Stop the currently playing audio clip
        }
    }
}

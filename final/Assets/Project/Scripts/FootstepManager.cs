using UnityEngine;

public class FootstepManager : MonoBehaviour
{
    public AudioClip leftFootstepSound; // Footstep sound for the left foot
    public AudioClip rightFootstepSound; // Footstep sound for the right foot
    public AudioSource audioSource; // Reference to a single AudioSource component
    
    [Range(0.1f, 3.0f)]
    public float footstepPitch = 1.0f; // Default pitch for footstep sounds

    public void FootstepEvent(int whichFoot)
    {
        if (audioSource.isPlaying)
        {
            audioSource.Stop(); // Stop any currently playing audio
        }

        switch (whichFoot)
        {
            case 0:
                audioSource.clip = leftFootstepSound; // Play left footstep sound
                break;
            case 1:
                audioSource.clip = rightFootstepSound; // Play right footstep sound
                break;
            default:
                Debug.Log("Invalid foot number");
                return;
        }

        audioSource.pitch = footstepPitch; // Set the pitch based on the editor value
        audioSource.Play(); // Play the selected footstep sound
    }

    public void StopFootstepSound()
    {
        if (audioSource.isPlaying)
        {
            audioSource.Stop(); // Stop the currently playing audio clip
        }
    }
}

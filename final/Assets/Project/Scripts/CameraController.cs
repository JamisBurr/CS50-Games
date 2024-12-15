using UnityEngine;
using Cinemachine;
using System.Collections;

public class CameraController : MonoBehaviour
{
    public CinemachineVirtualCamera followCamera;
    public CinemachineVirtualCamera aimCamera;

    // Switch to the aim camera
    public void SwitchToAimCamera()
    {
        followCamera.Priority = 0;
        aimCamera.Priority = 1;       
    }

    // Switch back to the follow camera
    public void SwitchToFollowCamera()
    {
        followCamera.Priority = 1;
        aimCamera.Priority = 0;
    }

  
}

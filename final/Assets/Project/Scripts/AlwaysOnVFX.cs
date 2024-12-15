using UnityEngine;
using UnityEngine.VFX;

public class AlwaysOnVFX : MonoBehaviour
{
    public VisualEffect vfxComponent;

    void Start()
    {
        if (vfxComponent == null)
            vfxComponent = GetComponent<VisualEffect>();
    }

    void Update()
    {
        // Check if the VFX graph needs to be always active
        if (!vfxComponent.isActiveAndEnabled)
        {
            vfxComponent.Play();
        }
    }
}

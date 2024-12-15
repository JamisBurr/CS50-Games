using UnityEngine;

public class CrosshairController : MonoBehaviour
{
    public Texture2D crosshairTexture; // Reference to the crosshair texture
    public Vector2 crosshairSize = new Vector2(32, 32); // Size of the crosshair

    void Start()
    {
        Cursor.visible = false; // Hide the system cursor
    }

    void OnGUI()
    {
        // Calculate the position to draw the crosshair texture
        Vector2 cursorPosition = new Vector2(Input.mousePosition.x, Screen.height - Input.mousePosition.y);
        Rect crosshairRect = new Rect(cursorPosition.x - (crosshairSize.x / 2), cursorPosition.y - (crosshairSize.y / 2), crosshairSize.x, crosshairSize.y);

        // Draw the crosshair texture
        GUI.DrawTexture(crosshairRect, crosshairTexture);
    }

    void OnDisable()
    {
        // Ensure the cursor is visible when the script is disabled (e.g., on scene change)
        Cursor.visible = true;
    }
}

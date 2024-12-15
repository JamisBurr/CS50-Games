using UnityEngine;
using UnityEngine.SceneManagement;
using Cinemachine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    public enum ControlScheme
    {
        KeyboardMouse,
        Gamepad
    }
    
    private CharacterController characterController;
    private Vector2 movementInput;
    private bool isMoving = false;
    private bool isAiming = false; // New boolean for shooting movement animations
    private Animator animator; // Reference to the Animator component
    private Transform cameraTransform; // Reference to the camera's transform   
    private PlayerInput playerInput; // Reference to the PlayerInput component    
    private AudioSource audioSource; // Reference to the AudioSource component

    public float gravity = -9.81f;
    public float moveSpeed = 7f;
    public float aimingSpeed = 2f;
    public float rotationSpeed = 720f; 
    public CinemachineVirtualCamera playerCamera;
    public CameraController cameraController;
    public FootstepManager footstepManager;
    public PlayerShooting playerShooting;
    public ControlScheme controlScheme; // Define the control scheme enum
    public AudioClip deathSound; // Audio clip for the death sound

    void Start()
    {
        characterController = GetComponent<CharacterController>();
        animator = GetComponent<Animator>(); // Get the Animator component
        cameraTransform = playerCamera.transform; // Get the camera's transform
        playerInput = GetComponent<PlayerInput>(); // Get the PlayerInput component
        audioSource = GetComponent<AudioSource>(); // Get the AudioSource component
    }

    void Update()
    {
        // Get camera's forward and right vectors
        Vector3 cameraForward = cameraTransform.forward;
        Vector3 cameraRight = cameraTransform.right;

        // Remove the y-component from camera vectors
        cameraForward.y = 0f;
        cameraRight.y = 0f;

        // Move the player based on input relative to camera orientation
        Vector3 moveDirection = (cameraForward * movementInput.y + cameraRight * movementInput.x).normalized;

        isMoving = movementInput.magnitude > 0;
        characterController.Move(moveDirection * moveSpeed * Time.deltaTime);

        // If aiming, rotate player towards input direction
        if (isAiming)
        {
            RotatePlayerTowardsInput(); // Call the new method to rotate based on input
            // Apply movement based on local direction relative to rotation
            Vector3 localMoveDirection = transform.InverseTransformDirection(moveDirection);
            characterController.Move(moveDirection * aimingSpeed * Time.deltaTime);
            animator.SetFloat("MoveX", localMoveDirection.x);
            animator.SetFloat("MoveZ", localMoveDirection.z);
        }
        else
        {
            // Rotate the player towards the movement direction relative to camera
            if (isMoving)
            {
                Quaternion targetRotation = Quaternion.LookRotation(moveDirection, Vector3.up);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, 360f * Time.deltaTime);
            }
            // Apply movement based on global direction
            animator.SetFloat("MoveX", movementInput.x);
            animator.SetFloat("MoveZ", movementInput.y);
        }

        if (!characterController.isGrounded)
        {
            characterController.Move(Vector3.up * gravity * Time.deltaTime);
        }

        // Update the isRunning parameter in the animator
        animator.SetBool("isRunning", movementInput.magnitude > 0);

        // Update the isShooting parameter in the animator
        animator.SetBool("isAiming", isAiming);
    }

    void RotatePlayerTowardsInput()
    {
        // Check the current control scheme
        switch (controlScheme)
        {
            case ControlScheme.KeyboardMouse:
                RotatePlayerTowardsMouse();
                break;
            case ControlScheme.Gamepad:
                RotatePlayerWithGamepad();
                break;
            default:
                Debug.LogError("Unknown control scheme!");
                break;
        }
    }

    void RotatePlayerTowardsMouse()
    {
        Ray ray = Camera.main.ScreenPointToRay(Mouse.current.position.ReadValue());
        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            Vector3 direction = hit.point - transform.position;
            direction.y = 0; // Keep the direction strictly horizontal
            if (direction.magnitude > 0.1f) // Check if the direction is significant
            {
                Quaternion targetRotation = Quaternion.LookRotation(direction, Vector3.up);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
            }
        }
    }

    void RotatePlayerWithGamepad()
    {
        Vector2 input = Gamepad.current.rightStick.ReadValue();
        Vector3 direction = new Vector3(input.x, 0, input.y);
        if (direction.magnitude > 0.1f) // Check if there is significant input
        {
            Quaternion targetRotation = Quaternion.LookRotation(direction, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }
    }

    public void OnMove(InputAction.CallbackContext context)
    {
        movementInput = context.ReadValue<Vector2>();
        isMoving = movementInput.magnitude > 0;

        // Manage footstep sounds based on the movement state
        if (isMoving)
        {
            // Assuming FootstepEvent requires a parameter indicating which footstep,
            // this part might need adjustment depending on how you decide to trigger
            // footsteps based on animation or time intervals.
            // For example, call FootstepEvent with a foot parameter if needed here.
        }
        else
        {
            // If the movement stops, immediately stop the footstep sounds
            footstepManager.StopFootstepSound();
        }
    }

    public void OnAim(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            isAiming = true;
            playerShooting.SetAiming(true); // Set aiming state in PlayerShooting script
            cameraController.SwitchToAimCamera();
        }
        else if (context.canceled)
        {
            isAiming = false;
            playerShooting.SetAiming(false); // Set aiming state in PlayerShooting script
            cameraController.SwitchToFollowCamera();
        }
    }

    // Method to handle shooting input
    public void OnFire(InputAction.CallbackContext context)
    {
        if (context.started) // Check if the shooting action has been triggered
        {
            animator.SetTrigger("Fire"); // Set the Shoot trigger in the Animator
            // Additional shooting logic (like firing bullets or projectiles) goes here
        }
    }

    public void SwitchControlScheme(ControlScheme newScheme)
    {
        controlScheme = newScheme;
    }

    public void Die()
    {
        Debug.Log("Player has died!"); // Log or handle player death
        // Disable player movement
        this.enabled = false;
        characterController.enabled = false;
        animator.SetTrigger("Die"); // Assuming you have a 'Die' animation

        // Play the death sound
        if (deathSound != null)
        {
            audioSource.PlayOneShot(deathSound);
        }

        // Stop the timer
        TimerController timerController = FindObjectOfType<TimerController>();
        if (timerController != null)
        {
            timerController.StopTimer();
            // Store the timer value in GameOverData
            GameOverData.TimerValue = timerController.GetFormattedTime();
        }

        // Start coroutine to transition to GameOver scene after 3 seconds
        StartCoroutine(TransitionToGameOverScene());
    }

    IEnumerator TransitionToGameOverScene()
    {
        yield return new WaitForSeconds(3f); // Wait for 3 seconds
        SceneManager.LoadScene("GameOverMenu"); // Load GameOverMenu scene
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Explosion"))  // Check if colliding object is tagged "Explosion"
        {
            Debug.Log("Player hit by explosion!");  // Log message for debugging
            Die();  // Call the Die method to handle player death
        }
    }
}

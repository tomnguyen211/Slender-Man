using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEditor.Search;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Rendering;
using URPGlitch.Runtime.AnalogGlitch;
using URPGlitch.Runtime.DigitalGlitch;

[RequireComponent(typeof(CharacterController))]
[DefaultExecutionOrder(-1)]
public class FPSCharacterController : MonoBehaviour, IDamage
{
    [Header("Input Settings")]
    [SerializeField] private string inputAxis_MoveHorizontal = "Horizontal";
    [SerializeField] private string inputAxis_MoveVertical = "Vertical";
    [SerializeField] private string inputAxis_MouseX = "Mouse X";
    [SerializeField] private string inputAxis_MouseY = "Mouse Y";

    [Header("Movement Settings")]
    [SerializeField, Min(0f)] private float moveSpeed_Walk = 2.2f;
    [SerializeField, Min(0f)] private float moveSpeed_Run = 4.0f;

    [Header("Camera Settings")]
    [SerializeField, Min(0f)] private float cameraHeight = 1.7f;
    [SerializeField] private float cameraMouseSensitivity = 1f;
    [SerializeField] private float cameraMinPitch = 0f;
    [SerializeField] private float cameraMaxPitch = 0f;
    [SerializeField] private Transform cameraTransform = null;

    [SerializeField]
    private bool runInputHeld = false;

    private bool manaIEnumeratorRunning = false;
    IEnumerator manaIEnumerator;

    private float cameraPitch;
    private float cameraYaw;

    private Vector3 movementInput = Vector3.zero;
    private Vector3 inputMouseDelta = Vector3.zero;

    public CharacterController characterController = null;
    private FPSHandsController handController = null;

    #region Health, Manar
    [SerializeField]
    private float maxHealth;
    [ReadOnly]
    public float currentHealth;
    [SerializeField]
    private float maxMana;
    [ReadOnly]
    public float currentMana;
    public ScreenDamage ScreenDamage;
    [ReadOnly]
    GameObject Attacker;
    #endregion

    public bool isOutside = true;

    [SerializeField]
    MovementManager MovementManager;

    [SerializeField]
    AudioSource heartBeat_Sound;

    [SerializeField]
    AudioSource Wind_Sound;
    [SerializeField]
    AudioClip[] windSoundVariants;

    [SerializeField]
    Volume volume;

    DigitalGlitchVolume digitalGlitchVolume;
    AnalogGlitchVolume analogGlitchVolume;

    [SerializeField]
    private int glitchStage = 0;
    public bool isGlitch;
    Coroutine Glitch_Coroutine;
    public bool stopGlitch;
    Coroutine Glitch_Coroutine_Stop;
    List<GameObject> SlenderObj;

    [SerializeField]
    AudioClip[] interferece;
    [SerializeField]
    AudioSource glitchSound;

    private UnityAction<int> triggerEvent;

    [SerializeField]
    AudioClip[] jumpScareSound;
    [SerializeField]
    AudioSource jumpjumpScareSource;

    private bool finalEventActivate;
    [SerializeField]
    AudioSource scaryLoopSound;

    public bool immueDamage;
    public bool immobilized;

    private void OnEnable()
    {

        EventManager.StartListening("PlayerTeleport", Teleport);
        EventManager.StartListening("HeartBeatSound", HeartBeatSound);
        EventManager.StartListening("TriggerWindSound", TriggerWindSound);
        EventManager.StartListening("JumpScareSound", JumpScareSound);
        EventManager.StartListening("FinalEvent", FinalEvent);
        EventManager.StartListening("EndGame_Player", EndGame_Player);



        triggerEvent += UpdateStatic;

        MovementManager.isMoving += IsMoving;
    }

    private void OnDisable()
    {

        EventManager.StopListening("PlayerTeleport", Teleport);
        EventManager.StopListening("HeartBeatSound", HeartBeatSound);
        EventManager.StopListening("TriggerWindSound", TriggerWindSound);
        EventManager.StopListening("JumpScareSound", JumpScareSound);
        EventManager.StopListening("FinalEvent", FinalEvent);
        EventManager.StopListening("EndGame_Player", EndGame_Player);



        triggerEvent -= UpdateStatic;

        MovementManager.isMoving -= IsMoving;

    }

    private void Awake()
    {
        TryGetComponent(out characterController);
        TryGetComponent(out handController);

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        if (cameraTransform != null)
        {
            Vector3 cameraEuler = cameraTransform.rotation.eulerAngles;
            cameraPitch = cameraEuler.x;
            cameraYaw = cameraEuler.y;
        }

        SlenderObj = new List<GameObject>();

        
    }

    private void Start()
    {
        ScreenDamage.maxHealth = ScreenDamage.CurrentHealth = currentHealth = maxHealth;
        currentMana = maxMana;
        handController.currentBattery = handController.batteryMax;

        GameManager.Instance.CharacterBar.Init(maxHealth, maxMana, handController.batteryMax);

        volume.profile.TryGet(out digitalGlitchVolume);
        volume.profile.TryGet(out analogGlitchVolume);

        StartCoroutine(WindForest_Control());

        EventManager.TriggerEvent("StartFadeOut",0.25f);
    }

    private void Update()
    {
        if (cameraTransform == null)
        {
            Debug.LogError($"{GetType().Name}.Update(): cameraTransform reference is null - exiting early & disabling component", gameObject);
            this.enabled = false;
            return;
        }

        if(!immobilized)
        {
            UpdateInput();
            UpdateTransform();
            UpdateCameraRotation();
        }
    }

    private void LateUpdate()
    {
        if (cameraTransform == null)
        {
            Debug.LogError($"{GetType().Name}.LateUpdate(): cameraTransform reference is null - exiting early & disabling component", gameObject);
            this.enabled = false;
            return;
        }

        UpdateCameraPosition();
        Mana();
    }

    private void UpdateInput()
    {
        runInputHeld = Input.GetKey(KeyCode.LeftShift);

        movementInput = new Vector2(Input.GetAxis(inputAxis_MoveHorizontal), Input.GetAxis(inputAxis_MoveVertical));
        movementInput = Vector2.ClampMagnitude(movementInput, 1.0f);

        inputMouseDelta = new Vector2(Input.GetAxis(inputAxis_MouseX), Input.GetAxis(inputAxis_MouseY));
    }

    private void UpdateCameraRotation()
    {
        cameraYaw += inputMouseDelta.x * cameraMouseSensitivity;
        cameraPitch += -inputMouseDelta.y * cameraMouseSensitivity;
        cameraPitch = Mathf.Clamp(cameraPitch, cameraMinPitch, cameraMaxPitch);

        if (cameraYaw < -180) cameraYaw += 360f;
        if (cameraYaw > 180f) cameraYaw -= 360f;

        if (cameraPitch < -180f) cameraPitch += 360f;
        if (cameraPitch > 180f) cameraPitch -= 360f;

        cameraTransform.rotation = Quaternion.Euler(cameraPitch, cameraYaw, 0f);

    }

    private void UpdateCameraPosition()
    {
        cameraTransform.position = transform.position + cameraHeight * transform.up;
    }

    private void UpdateTransform()
    {
        Vector3 cameraHorizontalForward = cameraTransform.forward;
        cameraHorizontalForward.y = 0;
        cameraHorizontalForward.Normalize();

        if (cameraHorizontalForward != Vector3.zero)
            transform.forward = cameraHorizontalForward;

        float moveSpeed = 0;

        if (currentMana > 0 && runInputHeld)
        {
            moveSpeed = moveSpeed_Run;
            MovementManager.SetPaceTimerRandom(0.01f);
            MovementManager.SetPaceTimer(0.3f);
        }
        else
        {
            moveSpeed = moveSpeed_Walk;
            MovementManager.SetPaceTimerRandom(0.05f);
            MovementManager.SetPaceTimer(0.5f);
        }


        //float moveSpeed = runInputHeld ? moveSpeed_Run : moveSpeed_Walk;

        Vector3 moveVector = Time.deltaTime * moveSpeed * (movementInput.x * transform.right + movementInput.y * transform.forward);
        moveVector.y = Time.deltaTime * Physics.gravity.y;

        characterController.Move(moveVector);
    }

    public bool IsRunning()
    {
        if (characterController.isGrounded == false)
            return false;

        Vector3 velocity = characterController.velocity;
        velocity.y = 0f;
        return runInputHeld && velocity.sqrMagnitude > 0.1f && currentMana > 0;
    }

    public bool IsWalking()
    {
        if (characterController.isGrounded == false)
            return false;
        Vector3 velocity = characterController.velocity;
        return velocity.sqrMagnitude > 0.1f && !runInputHeld;

    }

    public float GetMoveVelocityMagnitude()
    {
        if (characterController.isGrounded == false)
            return 0f;

        var velocity = characterController.velocity;
        velocity.y = 0f;
        return velocity.magnitude;
    }

    public void Damage(float damage, GameObject attacker)
    {
        if(!immueDamage)
        {
            currentHealth -= damage;
            ScreenDamage.CurrentHealth -= damage;
            Attacker = attacker;
            GameManager.Instance.CharacterBar.TakeDamage(damage);
            if (currentHealth <= 0f)
            {
                immueDamage = true;
                EventManager.TriggerEvent("PlayerSpawn");
                Destroy(gameObject);
            }
        }
    }

    public void Mana()
    {
        if(runInputHeld && !manaIEnumeratorRunning && currentMana > 0)
        {
            manaIEnumeratorRunning = true;
            manaIEnumerator = ManaChange_Deduct();
            StartCoroutine(manaIEnumerator);
        }
        else if(currentMana < maxMana && !runInputHeld && !manaIEnumeratorRunning)
        {
            manaIEnumeratorRunning = true;
            manaIEnumerator = ManaChange_Add();
            StartCoroutine(manaIEnumerator);
        }
    }

    IEnumerator ManaChange_Add()
    {
        float time = 1;
        while (time > 0)
        {
            time -= Time.deltaTime;
            if (runInputHeld)
            {
                manaIEnumeratorRunning = false;
                StopCoroutine(manaIEnumerator);
                yield break;
            }
            yield return null;
        }

        time = 0.05f;

        while (!runInputHeld && currentMana < maxMana)
        {
            time -= Time.smoothDeltaTime;

            if(time < 0f)
            {
                currentMana += 1;
                GameManager.Instance.CharacterBar.RefreshMana(1, 1);
                time = 0.05f;
            }
            yield return null;
        }
        manaIEnumeratorRunning = false;
        StopCoroutine(manaIEnumerator);

    }

    IEnumerator ManaChange_Deduct()
    {
        float time = 0.1f;

        while (runInputHeld && currentMana > 0)
        {
            time -= Time.smoothDeltaTime;

            if (time < 0f)
            {
                currentMana -= 1;
                GameManager.Instance.CharacterBar.UseMana(1, 1);
                time = 0.1f;
            }
            yield return null;
        }
        manaIEnumeratorRunning = false;
        StopCoroutine(manaIEnumerator);
    }

    public float GetHealth => currentHealth;
    public float GetMaxHealth => maxHealth;

    public float GetFirstAbilityBar => currentMana;
    public float GetFirstAbilityBarMax => maxMana;

   /* public float GetSecondAbilityBar => Stats_Manager.specialAbilityBarCount_2;
    public float GetSeocondManaAbilityMax => Stats_Manager.SpecialAbilityBar_2.BaseValue;*/


    private void Teleport(object pos)
    {
        Vector3 newPos = (Vector3)pos;
        transform.position = new Vector3(newPos.x,newPos.y,newPos.z);
    }

    private bool IsMoving()
    {
        if (movementInput != Vector3.zero)
            return true;
        return false;
    }

    private void HeartBeatSound(object isEnable)
    {
        if((bool)isEnable)
            heartBeat_Sound.Play();
        else
            heartBeat_Sound.Stop();
    }

    private void JumpScareSound()
    {
        jumpjumpScareSource.clip = jumpScareSound[Random.Range(0, jumpScareSound.Length)];
        jumpjumpScareSource.Play();

    }

    private void TriggerWindSound(object isEnable)
    {
        if ((bool)isEnable)
        {
            Wind_Sound.clip = windSoundVariants[Random.Range(0, windSoundVariants.Length)];
            Wind_Sound.Play();
        }
        else
        {
            Wind_Sound.Stop();
        }
    }

    IEnumerator WindForest_Control()
    {
        yield return new WaitForSeconds(Random.Range(30, 60));
        if(isOutside && !Wind_Sound.isPlaying)
        {
            TriggerWindSound(true);
        }
        StartCoroutine(WindForest_Control());
    }

    public void Glitch_Damage_Enable(GameObject a, bool cont)
    {
        if(!immueDamage)
        {
            if (!isGlitch || cont)
            {
                isGlitch = true;
                stopGlitch = false;

                if (Glitch_Coroutine != null)
                    StopCoroutine(Glitch_Coroutine);
                if (Glitch_Coroutine_Stop != null)
                    StopCoroutine(Glitch_Coroutine_Stop);

                if (finalEventActivate)
                {
                    if (glitchStage < 2)
                        glitchStage++;
                }
                else
                {
                    if (glitchStage < 5)
                        glitchStage++;
                }


                switch (glitchStage)
                {
                    case 1:
                        Glitch_Coroutine = StartCoroutine(GlitchCour_Increase(5));
                        triggerEvent.Invoke(1);
                        break;
                    case 2:
                        Glitch_Coroutine = StartCoroutine(GlitchCour_Increase(7));
                        triggerEvent.Invoke(2);
                        Damage(2, a);
                        break;
                    case 3:
                        Glitch_Coroutine = StartCoroutine(GlitchCour_Increase(7));
                        triggerEvent.Invoke(3);
                        Damage(4, a);
                        break;
                    case 4:
                        Glitch_Coroutine = StartCoroutine(GlitchCour_Increase(8));
                        triggerEvent.Invoke(4);
                        Damage(6, a);
                        break;
                    case 5:
                        Glitch_Coroutine = StartCoroutine(GlitchCour_Increase(10));
                        triggerEvent.Invoke(5);
                        Damage(10, a);
                        break;
                    default:
                        break;

                }
            }

            for (int i = 0; i < SlenderObj.Count; i++)
            {
                if (SlenderObj[i] == null)
                    SlenderObj.RemoveAt(i);
            }

            if (a != null && !SlenderObj.Contains(a))
            {
                SlenderObj.Add(a);
            }
        }       
    }

    public void Glitch_Damage_Disable(GameObject a, bool cont)
    {
        for (int i = 0; i < SlenderObj.Count; i++)
        {
            if (SlenderObj[i] == null)
                SlenderObj.RemoveAt(i);
        }

        if (a != null && SlenderObj.Contains(a))
        {
            SlenderObj.Remove(a);
        }

        if ((SlenderObj.Count <= 0 && !stopGlitch) || cont)
        {
            if (Glitch_Coroutine != null)
                StopCoroutine(Glitch_Coroutine);
            if (Glitch_Coroutine_Stop != null)
                StopCoroutine(Glitch_Coroutine_Stop);

            isGlitch = false;
            stopGlitch = true;

            if (glitchStage <= 0)
            {
                triggerEvent.Invoke(0);
                stopGlitch = false;
                return;
            }

            switch (glitchStage)
            {
                case 1:
                    Glitch_Coroutine_Stop = StartCoroutine(GlitchCour_Decrease(4));
                    triggerEvent.Invoke(1);
                    break;
                case 2:
                    Glitch_Coroutine_Stop = StartCoroutine(GlitchCour_Decrease(3));
                    triggerEvent.Invoke(2);
                    break;
                case 3:
                    Glitch_Coroutine_Stop = StartCoroutine(GlitchCour_Decrease(3));
                    triggerEvent.Invoke(3);
                    break;
                case 4:
                    Glitch_Coroutine_Stop = StartCoroutine(GlitchCour_Decrease(3));
                    triggerEvent.Invoke(4);
                    break;
                case 5:
                    Glitch_Coroutine_Stop = StartCoroutine(GlitchCour_Decrease(3));
                    triggerEvent.Invoke(5);
                    break;
                default:
                    Glitch_Coroutine_Stop = StartCoroutine(GlitchCour_Decrease(2));
                    break;
            }
            glitchStage--;
        }
    }

    IEnumerator GlitchCour_Increase(float time)
    {
        while (isGlitch)
        {
            time -= Time.deltaTime;
            if(time < 0)
            {
                Glitch_Damage_Enable(null, true);
            }
            
            yield return null;
        }
    }

    IEnumerator GlitchCour_Decrease(float time)
    {
        while (stopGlitch)
        {
            time -= Time.deltaTime;
            if(time < 0)
            {
                Glitch_Damage_Disable(null, true);
            }
            yield return null;
        }
    }

    public void UpdateStatic(int glitchStage)
    {
        switch (glitchStage)
        {
            case 0:
                digitalGlitchVolume.intensity.value = 0f;
                analogGlitchVolume.colorDrift.value = 0f;
                analogGlitchVolume.horizontalShake.value = 0f;
                analogGlitchVolume.verticalJump.value = 0f;
                analogGlitchVolume.scanLineJitter.value = 0f;
                glitchSound.Stop(); 
                break;
            case 1:
                digitalGlitchVolume.intensity.value = 0.1f;
                analogGlitchVolume.colorDrift.value = 0.1f;
                analogGlitchVolume.horizontalShake.value = 0.1f;
                analogGlitchVolume.verticalJump.value = 0.1f;
                analogGlitchVolume.scanLineJitter.value = 0.1f;
                glitchSound.clip = interferece[Random.Range(0,interferece.Length)];
                glitchSound.volume = 0.4f;
                glitchSound.Play();
                break;
            case 2:
                digitalGlitchVolume.intensity.value = 0.2f;
                analogGlitchVolume.colorDrift.value = 0.2f;
                analogGlitchVolume.horizontalShake.value = 0.2f;
                analogGlitchVolume.verticalJump.value = 0.1f;
                analogGlitchVolume.scanLineJitter.value = 0.2f;
                glitchSound.clip = interferece[Random.Range(0, interferece.Length)];
                glitchSound.volume = 0.6f;
                glitchSound.Play();
                break;
            case 3:
                digitalGlitchVolume.intensity.value = 0.3f;
                analogGlitchVolume.colorDrift.value = 0.3f;
                analogGlitchVolume.horizontalShake.value = 0.3f;
                analogGlitchVolume.verticalJump.value = 0.4f;
                analogGlitchVolume.scanLineJitter.value = 0.3f;
                glitchSound.clip = interferece[Random.Range(0, interferece.Length)];
                glitchSound.volume = 0.8f;
                glitchSound.Play();
                break;
            case 4:
                digitalGlitchVolume.intensity.value = 0.4f;
                analogGlitchVolume.colorDrift.value = 0.4f;
                analogGlitchVolume.horizontalShake.value = 0.4f;
                analogGlitchVolume.verticalJump.value = 0.2f;
                analogGlitchVolume.scanLineJitter.value = 0.4f;
                glitchSound.clip = interferece[Random.Range(0, interferece.Length)];
                glitchSound.volume = 1f;
                glitchSound.Play();
                break;
            case 5:
                digitalGlitchVolume.intensity.value = 0.5f;
                analogGlitchVolume.colorDrift.value = 0.5f;
                analogGlitchVolume.horizontalShake.value = 0.5f;
                analogGlitchVolume.verticalJump.value = 0.3f;
                analogGlitchVolume.scanLineJitter.value = 0.5f;
                glitchSound.clip = interferece[Random.Range(0, interferece.Length)];
                glitchSound.volume = 1f;
                glitchSound.Play();
                break;
        }
    }

    private void FinalEvent()
    {
        scaryLoopSound.Play();
        if (glitchStage > 2)
        {
            glitchStage = 2;
            triggerEvent.Invoke(3);
        }
        finalEventActivate = true;
    }

    public void EndGame_Player()
    {
        if (Glitch_Coroutine != null)
            StopCoroutine(Glitch_Coroutine);
        if (Glitch_Coroutine_Stop != null)
            StopCoroutine(Glitch_Coroutine_Stop);
        isGlitch = false;
        stopGlitch = false;
        glitchStage = 0;
        triggerEvent.Invoke(0);
        immueDamage = true;
        immobilized = true;
        EventManager.TriggerEvent("StartFadeIn",0.1f); ;
        // Text //
    }
}
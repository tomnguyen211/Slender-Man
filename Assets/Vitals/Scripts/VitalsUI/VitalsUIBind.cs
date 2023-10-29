using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace Vitals
{
    /// <summary>
    /// A MonoBehaviour responsible for binding VitalsHook data to the UI.
    /// </summary>
    [DefaultExecutionOrder(10)]
    public class VitalsUIBind : MonoBehaviour
    {
        /// <summary>
        /// The VitalsHook to bind to the UI.
        /// </summary>
        [SerializeField] private VitalsHook vitalsHook;
        
        #region UI Settings

        
        [SerializeField] private UIType uiType;
        
        /// <summary>
        /// The type of UI element used to display vitals data.
        /// </summary>
        public UIType UIType => uiType;

        /// <summary>
        /// Reference to the UI element that displays the vitals data.
        /// </summary>
        [SerializeField] private Image fillImage;
        
        /// <summary>
        /// Reference to the UI element that displays the vitals data.
        /// </summary>
        [SerializeField] private Slider slider;

        
        [SerializeField] private bool showTextFields;
        
        /// <summary>
        /// Determines if the text fields for the vitals data should be shown.
        /// </summary>
        public bool ShowTextFields => showTextFields;
        
        /// <summary>
        /// Optional reference to the UI element that displays the current value of the vitals data.
        /// </summary>
        [SerializeField] private Text valueText;
        
        /// <summary>
        /// Optional reference to the UI element that displays the maximum value of the vitals data.
        /// </summary>
        [SerializeField] private Text maxValueText;

        /// <summary>
        /// Enable if UI binding is setup through code.
        /// </summary>
        [Header("[Optional]"), SerializeField, Tooltip("If UI binding is setup through code, enabling this will disable the Debug.Log that checks for binding on Awake")] 
        private bool boundThroughCode;
        
        /// <summary>
        /// If enabled, the UI will animate the changes. If false, the UI will update instantly.
        /// </summary>
        [Header("Animation"), SerializeField] private bool animateChanges;
        public bool AnimateChanges => animateChanges;

        [SerializeField] private float animationDuration = 0.5f;
        [SerializeField] private AnimationCurve animationCurve = AnimationCurve.Linear(0, 0, 1, 1);
        
        
        #endregion

        #region Delegate
        
        /// <summary>
        /// Delegate used to update the UI based on the used UI element (Image/Slider).
        /// </summary>
        private Action<float, float, bool> _updateUI;

        #endregion

        #region Private Fields

        private Coroutine _animateCoroutine;

        #endregion
        
        #region Unity Methods

        private void Awake()
        {
            if (!vitalsHook && !boundThroughCode)
            {
                Debug.Log("Vitals Hook is not assigned on " + gameObject.name + " game object.");
            }
        }

        /// <summary>
        /// Assigns the delegate based on the UIType and subscribes to the OnValueChanged event.
        /// </summary>
        private void OnEnable()
        {
            switch (uiType)
            {
                case UIType.Image:
                {
                    _updateUI = UpdateImage;
                    if (!fillImage)
                    {
                        Debug.LogError("Fill Image is not assigned on " + gameObject.name + " game object.");
                        return;
                    }

                    break;
                }
                case UIType.Slider:
                {
                    _updateUI = UpdateSlider;
                    if (!slider)
                    {
                        Debug.LogError("Slider is not assigned on " + gameObject.name + " game object.");
                        return;
                    }
                    slider.maxValue = 1;
                    break;
                }
            }
            
            if (!vitalsHook) return;

            if (!vitalsHook.Initialized)
            {
                Debug.Log("Vitals Hook is not initialized on " + gameObject.name + " game object.\n" +
                               "Please make sure that " + vitalsHook.name + " is assigned to a Health/Stamina component.");
                return;
            }
            vitalsHook.OnValueChanged += _updateUI;
        }
        
        private void OnDisable()
        {
            if (!vitalsHook) return;
            vitalsHook.OnValueChanged -= _updateUI;   
        }

        #endregion

        #region UI Update Methods

        /// <summary>
        /// Updates the UI Image element based on the VitalsHook data.
        /// This is automatically assigned to the delegate based on the UIType.
        /// </summary>
        private void UpdateImage(float value, float maxvalue, bool isDrain)
        {
            if (_animateCoroutine != null)
                StopCoroutine(_animateCoroutine);

            if (animateChanges && !isDrain)
            {
                _animateCoroutine = StartCoroutine(AnimateImage(value, maxvalue));
                return;
            }
            
            fillImage.fillAmount = VitalsUtility.GetPercentage(vitalsHook);

            if (!showTextFields) return;
            
            UpdateText();
        }
        
        /// <summary>
        /// Updates the UI Slider element based on the VitalsHook data.
        /// This is automatically assigned to the delegate based on the UIType.
        /// </summary>
        private void UpdateSlider(float value, float maxvalue, bool isDrain)
        {
            if (_animateCoroutine != null)
                StopCoroutine(_animateCoroutine);

            if (animateChanges && !isDrain)
            {
                _animateCoroutine = StartCoroutine(AnimateSlider(value, maxvalue));
                return;
            }
            
            slider.value = VitalsUtility.GetPercentage(vitalsHook);

            if (!showTextFields) return;
            
            UpdateText();
        }
        
        /// <summary>
        /// Updates the UI Text elements based on the VitalsHook data.
        /// </summary>
        private void UpdateText()
        {
            if (valueText)
                valueText.text = vitalsHook.Value.ToString("F0");
            if (maxValueText)
                maxValueText.text = vitalsHook.MaxValue.ToString("F0");
        }

        #endregion

        #region Animation

        /// <summary>
        /// Updates the UI Image element based on the VitalsHook data.
        /// </summary>
        private IEnumerator AnimateImage(float value, float maxValue)
        {
            float startValue = fillImage.fillAmount;
            float elapsedTime = 0f;
            float targetValue = VitalsUtility.GetPercentage(value, maxValue);
            
            while (elapsedTime < animationDuration)
            {
                elapsedTime += Time.deltaTime;
                float t = Mathf.Clamp01(elapsedTime / animationDuration);
                float animatedValue = Mathf.Lerp(startValue, targetValue, animationCurve.Evaluate(t));
                
                fillImage.fillAmount = animatedValue;
                yield return null;
            }
            
            fillImage.fillAmount = targetValue;

            if (showTextFields)
            {
                UpdateText();
            }
            
            _animateCoroutine = null;
        }

        /// <summary>
        /// Updates the UI Slider element based on the VitalsHook data.
        /// </summary>
        private IEnumerator AnimateSlider(float value, float maxValue)
        {
            float startValue = slider.value;
            float elapsedTime = 0f;
            float targetValue = VitalsUtility.GetPercentage(value, maxValue);

            while (elapsedTime < animationDuration)
            {
                elapsedTime += Time.deltaTime;
                float t = Mathf.Clamp01(elapsedTime / animationDuration);
                float animatedValue = Mathf.Lerp(startValue, targetValue, animationCurve.Evaluate(t));

                slider.value = animatedValue;

                yield return null;
            }

            // Ensure the slider value is set to the target value at the end
            slider.value = targetValue;

            if (showTextFields)
            {
                UpdateText();
            }

            _animateCoroutine = null;
        }
        
        #endregion

        #region Initialization

        /// <summary>
        /// Initializes the VitalsUIBind with a given VitalsHook.
        /// </summary>
        /// <param name="hook">The VitalsHook to bind to the UI.</param>
        public void Initialize(VitalsHook hook)
        {
            vitalsHook = hook;
            vitalsHook.OnValueChanged += _updateUI;
        }

        #endregion
    }
    
    public enum UIType { Image, Slider }
}

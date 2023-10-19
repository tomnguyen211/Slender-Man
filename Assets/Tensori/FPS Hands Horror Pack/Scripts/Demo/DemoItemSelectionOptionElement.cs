using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.UI;

namespace Tensori.FPSHandsHorrorPack.Demo
{
    public class DemoItemSelectionOptionElement : MonoBehaviour
    {
        public FPSItemSelector.InputItemOption OptionBinding { get; private set; } = null;

        [Header("Object References")]
        [SerializeField] private Text labelText = null;

        private bool isSelected = false;
        private Vector2 defaultSize;
        private Vector2 sizeVelocity;
        private RectTransform rectTransform = null;

        private void Awake()
        {
            rectTransform = transform as RectTransform;
            defaultSize = rectTransform.sizeDelta;
        }

        public void BindToOption(FPSItemSelector.InputItemOption option)
        {
            OptionBinding = option;

            if (option.ItemAsset == null)
            {
                gameObject.SetActive(false);
                return;
            }

            string inputName = option.InputKey.ToString();
            inputName = inputName.Replace("Alpha", string.Empty);

            labelText.text = $"[{inputName}] - {option.ItemAsset.name}";
        }

        public void UpdateSelectionHighlight(bool isSelected)
        {
            this.isSelected = isSelected;
        }

        private void Update()
        {
            rectTransform.sizeDelta = Vector2.SmoothDamp(
                rectTransform.sizeDelta, 
                isSelected ? defaultSize : 0.7f * defaultSize, 
                ref sizeVelocity, 
                smoothTime: 0.2f);
        }
    }
}
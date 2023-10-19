using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Tensori.FPSHandsHorrorPack.Demo
{
    public class DemoItemSelectionCanvas : MonoBehaviour
    {
        [Header("Object References")]
        [SerializeField] private DemoItemSelectionOptionElement selectionOptionPrefab = null;
        [SerializeField] private FPSItemSelector itemSelector = null;
        [SerializeField] private RectTransform verticalGroupParent = null;

        private List<DemoItemSelectionOptionElement> activeOptionElements = new List<DemoItemSelectionOptionElement>();

        private void Awake()
        {
            if (selectionOptionPrefab == null || itemSelector == null || verticalGroupParent == null)
                return;

            for (int i = 0; i < itemSelector.SelectionOptions.Count; i++)
            {
                var option = itemSelector.SelectionOptions[i];

                GameObject newOptionElement = Instantiate(selectionOptionPrefab.gameObject, parent: verticalGroupParent);
                newOptionElement.transform.SetAsLastSibling();

                if (newOptionElement.TryGetComponent(out DemoItemSelectionOptionElement optionElementComponent))
                {
                    optionElementComponent.BindToOption(option);
                    activeOptionElements.Add(optionElementComponent);
                }
            }

            itemSelector.OnItemSelected += this.onItemSelected;
        }

        private void onItemSelected(FPSItemSelector.InputItemOption option)
        {
            for (int i = 0; i < activeOptionElements.Count; i++)
            {
                var element = activeOptionElements[i];
                element.UpdateSelectionHighlight(isSelected: option == element.OptionBinding);
            }
        }
    }
}
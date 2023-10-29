
To improve performance, I recommend that you disable the "Cloth" components on objects.


Important Shader parameters: the "Distance" Parameter is responsible for the calculation 
of decals at a distance from 
the position of the decal to the pixel, it is necessary for optimization,
 put the value as little as possible,
the parameter "MaxDistanceDecal" is responsible for the rendering of
 decals on the distance from the camera,
this is necessary for optimization.

Script "decal" I advise you not
 to put a large number of decals.

If you have "Amplify shader editor" you can easily convert shaders to HDRP.
There are shaders for LWRP.

All materials have been set up in a linear color space,
 so materials may look different if you work in Gamma color space


 If you are reading this then you are using unity 2019.2 or higher, in this version of unity
 there are problems with tissue, so I disabled some elements that use tissue, guts and meat 
 on the neck, when unity developers fix the "Cloth" component I will include these elements,
 or if you want, you can include these elements in the zombie prefab (called object "ParentMeat"
 at the beginning of the hierarchy and "Gut" at the end of the hierarchy



Для того чтобы повысить производительность, рекомендую отключить компоненты "Cloth" на объектах.

Важные параметры шейдера: Параметр "Distance" он отвечает за просчет декалей на дистанции от 
позиции декали к пикселю, это необходимо для оптимизации, ставьте значение как можно меньше,
параметр "MaxDistanceDecal" отвечает за отрисовку декалей по дистанции от камеры,
это нужно для оптимизации.

Скрипт "decal" советую не ставить большое число декалей.

Если у вас есть "Amplify shader editor" то вы можете запросто переделать шейдеры под HDRP.
Шейдеры для LWRP есть.

Все материалы были настроены в линейном цветовом пространстве, поэтому материалы могут 
выглядеть иначе если вы работаете в Gamma color space

Если вы читаете это то вы используете unity 2019.2 или выше, в этой версии
unity есть проблемы с тканью, по этому я отключил некоторые элементы которые
используют ткань, кишки и мясо на шее, когда разработчики unity исправят компонент "Cloth" 
я включю эти элементы, или если хотите, вы можете сами включить эти элементы
в префабе zombie (называеться объект "ParentMeat" в начале иерархии и "Gut"  в конце иерархии
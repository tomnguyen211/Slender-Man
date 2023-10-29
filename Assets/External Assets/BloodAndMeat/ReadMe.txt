
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



��� ���� ����� �������� ������������������, ���������� ��������� ���������� "Cloth" �� ��������.

������ ��������� �������: �������� "Distance" �� �������� �� ������� ������� �� ��������� �� 
������� ������ � �������, ��� ���������� ��� �����������, ������� �������� ��� ����� ������,
�������� "MaxDistanceDecal" �������� �� ��������� ������� �� ��������� �� ������,
��� ����� ��� �����������.

������ "decal" ������� �� ������� ������� ����� �������.

���� � ��� ���� "Amplify shader editor" �� �� ������ �������� ���������� ������� ��� HDRP.
������� ��� LWRP ����.

��� ��������� ���� ��������� � �������� �������� ������������, ������� ��������� ����� 
��������� ����� ���� �� ��������� � Gamma color space

���� �� ������� ��� �� �� ����������� unity 2019.2 ��� ����, � ���� ������
unity ���� �������� � ������, �� ����� � �������� ��������� �������� �������
���������� �����, ����� � ���� �� ���, ����� ������������ unity �������� ��������� "Cloth" 
� ������ ��� ��������, ��� ���� ������, �� ������ ���� �������� ��� ��������
� ������� zombie (����������� ������ "ParentMeat" � ������ �������� � "Gut"  � ����� ��������
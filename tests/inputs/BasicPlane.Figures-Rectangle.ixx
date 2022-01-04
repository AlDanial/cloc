/*
https://docs.microsoft.com/en-us/cpp/cpp/tutorial-named-modules-cpp?view=msvc-170
*/
export module BasicPlane.Figures:Rectangle; // defines the module partition Rectangle

import :Point;

export struct Rectangle // make this struct visible to importers
{
    Point ul, lr;
};

// These functions are declared, but will
// be defined in a module implementation file
export int area(const Rectangle& r);
export int height(const Rectangle& r);
export int width(const Rectangle& r);

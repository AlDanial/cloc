// Hello World in C++ for Microsoft Foundation Classes
// (Microsoft Visual C++).
// from http://www.roesler-ac.de/wolfram/hello.htm

#include <afxwin.h>

class CHello : public CFrameWnd
{
public:
    CHello()
    {
        Create(NULL,_T("Hello World!"),WS_OVERLAPPEDWINDOW,rectDefault);
    }
};

class CHelloApp : public CWinApp
{
public:
    virtual BOOL InitInstance();
};

BOOL CHelloApp::InitInstance()
{
    m_pMainWnd = new CHello();
    m_pMainWnd->ShowWindow(m_nCmdShow);
    m_pMainWnd->UpdateWindow();
    return TRUE;
}

CHelloApp theApp;

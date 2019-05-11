% https://oit.colorado.edu/software-hardware/tex-latex/thesis-class/documentation-sample-files
%   (truncated)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% thesis.cls - LaTeX2e class for CU Theses.
%% To conform to the University of Colorado at Boulder
%%	Graduate School SPECIFICATIONS (April 2010) for
%%	Preparation of Master's Thesis and Doctoral Dissertations
%% Version 1.00 written by John P. Weiss, 1997
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	version 1.13, Hongcheng Ni, March 2014 -- made compatible with
%%		hyperref.
%%	version 1.12, Hongcheng Ni, March 2014 -- added title before
%%		the advisor's name in the signature page.
%%	version 1.11, Bruce Fast, April 2008 -- changed left margin
%%		from 1.75" to 1", and added \IRBprotocol option
%%	version 1.10, E. Joshua Rigler, January 2003 -- making it safe
%%		for folks who inadvertently load setspace.sty, changed
%%		\latex@xfloat to \latexx@xfloat
%%	version 1.09, BF, November 2000 -- conforms to revised specs
%%		no significant changes required
%%	version 1.08, Steven V Penton, September 1999 -- added
%%		\readerFive; moved list of tables in front of figures
%%	version 1.07, BF, January 1999 -- fixed \LoFisShort etc.
%%	version 1.06, BF, November 1998 -- fixed level 4 headers;
%%		SubSubSections, inline4 & nonum4.  Eliminated
%%		unwanted space before chapter/section numbers.
%%	version 1.05, BF, August 1998 -- Footnotes and floats
%%		(captions) now singlespaced, fixing an omission
%%		in v1.04.  Fixed value of \belowcaptionskip,
%%		for table captions.
%%	version 1.04, BF, July 1998, Adjusted doublespacing
%%		(no longer uses setspace.sty) and margin values.
%%	version 1.03, May 1998, Bruce Fast -- Added optional
%%		\readerThree{}, \readerFour{}; LoF/LoT debugging;
%%		doublespaced abstract
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{thesis}[2014/03/27]	% version 1.13

\typeout{}
\typeout{--------------------------------------------------------------}
\typeout{ +---+ Thesis Style (thesis.cls) version 1.13}
\typeout{ +---+ for University of Colorado Ph.D. theses/dissertations.}
\typeout{ * Conforms to the University of Colorado at Boulder Graduate}
\typeout{ * School "SPECIFICATIONS for Preparation of Master's Thesis}
\typeout{ * and Doctoral Dissertations" (rev. March 2014).}
\typeout{--------------------------------------------------------------}
\typeout{ URL: http://www.colorado.edu/oit/software-hardware/tex-latex}
\typeout{}

% Certain options are not handled here but are passed on to report.cls
% by \PassOptionToClass.

\DeclareOption{fleqn}{ \PassOptionsToClass{fleqn}{report} }
\DeclareOption{leqno}{ \PassOptionsToClass{leqno}{report} }
\DeclareOption{openbib}{ \PassOptionsToClass{openbib}{report} }
\DeclareOption{draft}{ \PassOptionsToClass{draft}{report} }
\DeclareOption{final}{ \PassOptionsToClass{final}{report} }
\DeclareOption{openright}{ \PassOptionsToClass{openright}{report} }
\DeclareOption{openany}{ \PassOptionsToClass{openany}{report} }
\DeclareOption{10pt}{ \PassOptionsToClass{10pt}{report} }
\DeclareOption{11pt}{ \PassOptionsToClass{11pt}{report} }
\DeclareOption{12pt}{ \PassOptionsToClass{12pt}{report} }

% Invalid options - normally used in report.cls and others, but not here:

\DeclareOption{titlepage}
   {\ClassWarning{thesis}{Title page always generated. Option ignored.}}
\DeclareOption{notitlepage}
   {\ClassWarning{thesis}{Option 'notitlepage' not available for thesis.}}
\DeclareOption{twoside}
   {\ClassWarning{thesis}{Option 'twoside' not available for thesis.}}
\DeclareOption{twocolumn}
   {\ClassWarning{thesis}{Option 'twocolumn' not available for thesis.}}
\DeclareOption{landscape}
   {\ClassWarning{thesis}{Option 'landscape' not available for thesis.}}
\DeclareOption{legalpaper}
   {\ClassWarning{thesis}{Option 'legalpaper' not available for thesis.}}
\DeclareOption{a4paper}
   {\ClassWarning{thesis}{Option 'a4paper' not available for this class.}}
\DeclareOption{a5paper}
   {\ClassWarning{thesis}{Option 'a5paper' not available for this class.}}
\DeclareOption{executivepaper}
   {\ClassWarning{thesis}{Option 'executivepaper' not available.}}
\DeclareOption{b5paper}
   {\ClassWarning{thesis}{Option 'b5paper' not available for this class.}}
\DeclareOption{letterpaper}
   {\ClassWarning{thesis}{Option 'letterpaper' superfluous. Ignored.}}
\DeclareOption{onecolumn}
   {\ClassWarning{thesis}{Option 'onecolumn' superfluous.  Ignored.}}
\DeclareOption{oneside}
   {\ClassWarning{thesis}{Option 'oneside' superfluous.  Ignored.}}

%%%%%%%%%%% CUSTOM OPTIONS:
% Options for no decimal numbering, or decimal number nested over 3 deep:
\newif\if@AllHeadings
\newif\if@NumberStdHeadings
\newif\if@PerChptrNumbering
\newif\if@emphisbold
\newif\if@boldhead
\newif\if@fixedHeadSz
\newif\if@headSizeTwelvePt
\newif\if@ChapterDefault
\newif\if@SectionDefault
\newif\if@SubSectionDefault
\newif\if@OtherHeadingDefault
\newif\if@centerChapter
\newif\if@centerSection
\newif\if@inlineSubSubSection
\newif\if@numberSubSubSection
\newif\if@chapterCaps
\@AllHeadingsfalse
\@NumberStdHeadingstrue
\@PerChptrNumberingtrue
\@emphisboldtrue
\@boldheadtrue
\@fixedHeadSzfalse
\@centerChaptertrue
\@centerSectionfalse
\@inlineSubSubSectionfalse
\@numberSubSubSectiontrue
\@chapterCapsfalse
\@headSizeTwelvePttrue
\DeclareOption{consecutivenumbering}{ \@PerChptrNumberingfalse }
\DeclareOption{inlineh4}{ \@inlineSubSubSectiontrue }
\DeclareOption{nonumh4}{ \@numberSubSubSectionfalse }
\DeclareOption{centerh1}{ \@centerSectiontrue }
\DeclareOption{chapleft}{ \@centerSectiontrue }
\DeclareOption{chapup}{ \@chapterCapstrue }
\DeclareOption{emph2underline}{ \@emphisboldfalse }
\DeclareOption{plainhead}{ \@boldheadfalse }
\DeclareOption{fixedheadsize}{ \@fixedHeadSztrue }
\DeclareOption{varheadsize}{\@headSizeTwelvePtfalse}% Hidden option.  Don't use.
\DeclareOption{numberchapteronly}{
	\@PerChptrNumberingfalse\@NumberStdHeadingsfalse\@AllHeadingsfalse
	\@centerChaptertrue\@centerSectiontrue
	\@inlineSubSubSectiontrue\@numberSubSubSectionfalse }
\DeclareOption{allheadings}{
	\@PerChptrNumberingtrue\@NumberStdHeadingstrue\@AllHeadingstrue
	\@centerChaptertrue\@centerSectionfalse
	\@inlineSubSubSectionfalse\@numberSubSubSectiontrue}
\DeclareOption{typewriterstyle}{ \@emphisboldfalse
	\@PerChptrNumberingfalse\@NumberStdHeadingsfalse\@AllHeadingsfalse
	\@centerChaptertrue\@centerSectiontrue\@chapterCapstrue
	\@inlineSubSubSectiontrue\@numberSubSubSectionfalse
	\@boldheadfalse\@fixedHeadSztrue}
\DeclareOption{modernstyle}{ \@emphisboldtrue
	\@PerChptrNumberingtrue\@NumberStdHeadingstrue\@AllHeadingsfalse
	\@centerChaptertrue\@centerSectionfalse\@chapterCapsfalse
	\@inlineSubSubSectiontrue\@numberSubSubSectionfalse
	\@boldheadtrue\@fixedHeadSzfalse}
\DeclareOption{defaultstyle}{ \@emphisboldtrue
	\@PerChptrNumberingtrue\@NumberStdHeadingstrue\@AllHeadingsfalse
	\@centerChaptertrue\@centerSectionfalse\@chapterCapsfalse
	\@inlineSubSubSectionfalse\@numberSubSubSectiontrue
	\@boldheadtrue\@fixedHeadSzfalse}
% lines deleted %
\endinput
%%%%%%%%%%%%%%%% End of file ``thesis.cls''

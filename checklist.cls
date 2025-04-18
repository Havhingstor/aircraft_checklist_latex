\ProvidesClass{checklist}
\NeedsTeXFormat{LaTeX2e}

% Class options
\RequirePackage{ifthen}
\newboolean{sim-use}
\newboolean{halfpage}
\newboolean{blue_items}
\DeclareOption{sim-use}{\setboolean{sim-use}{true}}
\DeclareOption{halfpage}{\setboolean{halfpage}{true}}
\DeclareOption{blue_items}{\setboolean{blue_items}{true}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\ifthenelse{\boolean{halfpage}}{
    \LoadClass[twocolumn, 11pt, a4paper]{article}
}{
    \LoadClass[onecolumn, 11pt, a4paper]{article}
}

% Define custom macro definitions
\newcommand{\logo}[1]{\def\@logo{#1}}
\newcommand{\subtitle}[1]{\def\@subtitle{#1}}
\newcommand{\version}[1]{\def\@version{#1}}

\RequirePackage{environ}
\RequirePackage{setspace}
\RequirePackage{svg}
\RequirePackage{xcolor}
\RequirePackage{ragged2e}

\newlength{\maxAssigneeLength}
\newlength{\newAssigneeLength}
\newboolean{assignee}

\newcommand{\registerAssigneeLength}[1]{
	\setboolean{assignee}{true}
	\settowidth{\newAssigneeLength}{\uppercase{#1}}
	
	\ifthenelse{\lengthtest{\maxAssigneeLength < \newAssigneeLength}}{
		\setlength{\maxAssigneeLength}{\newAssigneeLength}
	}{}
}

\definecolor{customblack}{gray}{0.15}
\newcommand{\blank}{\underline{\hspace{5mm}}}    % underlined empty space

% Change margin and column width
\RequirePackage{geometry}
\geometry{textwidth=7.25in, columnsep=0.35in, tmargin=1.0in, bmargin=2.25in}

% Change font family
\usepackage[scaled]{helvet}
\renewcommand\familydefault{\sfdefault} 
\usepackage[T1]{fontenc}


% Header and footer
\RequirePackage{fancyhdr}
\RequirePackage{tabularx, multirow, makecell, colortbl}
\setlength{\headheight}{1.7in}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\fancyfoot[L]{\ifthenelse{\boolean{sim-use}}{For simulation use only}{}}
\fancyfoot[R]{\ifthenelse{\boolean{blue_items}}{\color{blue}Blue items: Not required on through flights}{}}
\fancyhead[C]{%
    % \setlength{\extrarowheight}{0.6in}   % use \rule to specific row height instead
    \newcolumntype{C}{>{\centering\arraybackslash}m}
    \newcolumntype{Y}{>{\centering\arraybackslash}X}
    \newcolumntype{N}{@{}m{0pt}@{}}
    % \renewcommand{\tabularxcolumn}[1]{C{#1}}
    
    \begin{tabularx}{\textwidth}{|C{1.5in}|Y|C{1.5in}|N}
        \hline
        % https://tex.stackexchange.com/questions/445943/center-a-multirow -- 5 lines work better than 2
        \cellcolor{customblack} & & \cellcolor{customblack}\textcolor{white}{\makecell{\@subtitle}} & \rule{0pt}{4pc}\\
        \cline{3-3}
        \multirow{-5}{*}{\cellcolor{customblack}\includegraphics[width=1.5in]{\@logo}} &
        \multirow{-5}{*}{\LARGE{\@title}} &
        \makecell{\@version} & \rule{0pt}{4pc}\\        
        \hline
    \end{tabularx}%    
}


% For creating box around each section
\RequirePackage{tcolorbox}
\tcbset{colback=white, colframe=customblack, arc=0mm, beforeafter skip=6mm,
    fonttitle=\bfseries\large, halign title=center, 
    boxsep=0mm, toptitle=3mm, bottomtitle=3mm, top=4mm, bottom=4mm}

\newboolean{customcasing}
\newboolean{specialitem}
\setboolean{customcasing}{false}
\setboolean{specialitem}{false}

% Checklist environment for each section
\newenvironment{checklist}[1]{%
    \begin{tcolorbox}[title=\uppercase{#1}]
    \setstretch{1.1}
    \begin{_checklist_internal}
}{
    \end{_checklist_internal}
    \end{tcolorbox}
}

\newenvironment{continuedchecklist}{%
    \begin{tcolorbox}[]
    \setstretch{1.1}
    \begin{_checklist_internal}
}{
    \end{_checklist_internal}
    \end{tcolorbox}
}
    
\newenvironment{_checklist_internal}{%
    \newcommand{\indentinternal}{\hspace{0em}}
    \newcommand{\spacednewline}{\phantom{\ifthenelse{\boolean{assignee}}{ - \hspace{\maxAssigneeLength}}{}}\newline}
    \renewcommand{\\}{\spacednewline}
    \setboolean{customcasing}{false}
    \setboolean{specialitem}{false}
    \newcommand{\casinginternal}[1]{\ifthenelse{\boolean{customcasing}}{##1}{\uppercase{##1}}}
    \newcommand{\specialinternal}{\ifthenelse{\boolean{specialitem}}{\color{blue}}{}}
    
    \RenewDocumentCommand{\item}{mmO{}}{%
        {\specialinternal \indentinternal \RaggedRight ##1\,\dotfill\,\RaggedLeft \casinginternal{##2}\ifthenelse{\boolean{assignee}}{ - \makebox[\maxAssigneeLength][r]{\uppercase{##3}}}{} \newline}
    }
    \NewDocumentCommand{\itemcustcase}{mmO{}}{%
        \setbool{customcasing}{true}
        \item{##1}{##2}[##3]
        \setbool{customcasing}{false}
    }
    \NewDocumentCommand{\specialitem}{mmO{}}{%
        \setbool{specialitem}{true}
        \item{##1}{##2}[##3]
        \setbool{specialitem}{false}
    }
    \NewDocumentCommand{\specialitemcustcase}{mmO{}}{%
        \setbool{customcasing}{true}
        \setbool{specialitem}{true}
        \item{##1}{##2}[##3]
        \setbool{specialitem}{false}
        \setbool{customcasing}{false}
    }
	\renewcommand{\line}{\rule{\textwidth}{0.5pt}\vspace{1.3ex} \newline}

    \newcommand{\condition}[2]{%
        \renewcommand{\indentinternal}{\hspace{1.5em}}
        \renewcommand{\\}{\spacednewline\indentinternal}
        \RaggedRight \textit{##1} \newline ##2
        \renewcommand{\\}{\spacednewline}
        \renewcommand{\indentinternal}{\hspace{0em}}
    }
}{}

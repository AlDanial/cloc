%{
https://www.mathworks.com/matlabcentral/fileexchange/42673-beautiful-and-distinguishable-line-colors-colormap
%}

% LINE COLORS
N=6;
X = linspace(0,pi*3,1000);
Y = bsxfun(@(x,n)sin(x+2*n*pi/N), X.', 1:N);
C = linspecer(N);
axes('NextPlot','replacechildren', 'ColorOrder',C);
plot(X,Y,'linewidth',5)
ylim([-1.1 1.1]);

%{
  SIMPLER LINE COLOR EXAMPLE
%}
N = 6; X = linspace(0,pi*3,1000);
C = linspecer(N)
hold off;
for ii=1:N
Y = sin(X+2*ii*pi/N);
plot(X,Y,'color',C(ii,:),'linewidth',3);
hold on;
end

%{
  COLORMAP EXAMPLE
%}
A = rand(15);
figure; imagesc(A); % default colormap
figure; imagesc(A); colormap(linspecer); % linspecer colormap

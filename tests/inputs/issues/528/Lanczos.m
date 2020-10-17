function [phiKM, AscendingLambda] = Lanczos(K, M, sigma, Jmax)
[rows,cols] = size(K);                                                       
if (rows ~= cols)                                                       
  fprintf('Lanczos needs square matrices');                
end                                                       
Z       = K - sigma*M;                               % initialize some
Q       = zeros(rows,Jmax+1);                        % variables
T       = zeros(Jmax,Jmax);                          %
rRand   = randn(rows,1);                             %
rOld = rRand;
betaOld = sqrt(rOld'*M*rOld);                        %
for j = 1:Jmax,                                      %
  Q(:,j+1) = rOld/betaOld;                           %
  u = Z \ (M*Q(:,j+1) - Z*Q(:,j)*betaOld);           % D.S.Scott's formulation
  alpha = Q(:,j+1)'*M*u;                             % of the recurrence
  r     = u - alpha*Q(:,j+1);                        %
  for i=1:3,                                         %
    sum = zeros(rows,1);                             % repeat a full orhto-
    for k=2:j+1,                                     % gonalization three
      sum = sum + (Q(:,k)'*M*r)*Q(:,k);              % times to ensure
    end;                                             % high quality
    r = r - sum;                                     % solutions
  end;                                               %
  beta = sqrt(r'*M*r);                               %
  T(j,j)   = alpha;                                  %
  if (j ~= Jmax)                                     % augment [T] with new
    T(j+1,j) = beta;                                 % alpha_i, beta_i+1
    T(j,j+1) = beta;                                 %
  end;                                               %
  Jactual = j;                                       %
  if (abs(beta) < 1.0e-12)                           % singular beta; going
    break                                            % any more will introduce
  end                                                % spurious modes
  betaOld = beta;                                    %
  rOld    = r;                                       %
end                                                  %
[phiT,lambdaT] = eig(T(1:Jactual,1:Jactual));        % solve [T]{y} = L{y}
lambdaKM   = zeros(Jactual,1);                       %
for j = 1:Jactual,                                   % invert and shift the
  lambdaKM(j) = sigma + 1/lambdaT(j,j);              % eigenvalues to the
end                                                  % user's domain
[AscendingLambda, ordering] = sort(lambdaKM);        %
phiKM      = zeros(rows,Jactual);                    % sort the eigenvalues
UnOrdphiKM = zeros(rows,Jactual);                    % in ascending order
UnOrdphiKM = Q(:,2:Jactual+1)*phiT;                  %
for j = 1:Jactual,                                   % resequence the e-vectors
  phiKM(:,j) = UnOrdphiKM(:,ordering(j));            % to correspond to the
end                                                  % e-values

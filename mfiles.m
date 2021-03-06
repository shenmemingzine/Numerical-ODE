%The following are the M-files needed to do the experiment 
%for linear multistep methods. To use a different method, change 
%the parameter p in hw12.m and change the file method.m. For linear multistep
%methods, only the parameters alpha and beta need to be changed in method.m.
%For the other methods, method.m has to be completely rewritten. At 
%present, method.m implements method 2 of the homework problem. 
%The code tries to minimize the number of evaluations of the 
%function f(x,y). Therefore the last (p+1) evaluations of f(x,y) 
%are stored in the matrix f.



% driver for numerical experiments in homework 
%Need to specify h before running it.
%Change only parameter p when using different methods.
% Input parameters:
a = 0; % left side of integration interval
eta = [2.6726e-01; -5.3452e-01; 8.0178e-01]; % initial value (column vector)
p = 2; % parameter p of method. p=0: single step, p>0: multistep
% end of input

format short e
global count ; %counter for evaluations of function f(x,y)
count = 0;
h = 0.001025;
A = [200 398 198; -500 -696 -296; 500 694 294];
m = max(size(eta)); % number of equations
y = zeros(m,p+1); f=y; 
for j=1:p                    %initialize matrices y and f.
  y(:,j+1) = exact_sol_linear_ivp(a+j*h, A, a, eta); %The (j+1)-th column of y contains y(a+j*h)
  f(:,j+1) = fun(a+j*h,y(:,j+1)); % compute f(a+j*h,y(a+j*h))
end                 
y(:,1) = eta; f(:,1) = fun(a,eta);

nstep = .2/h;
xn = a+p*h;
for k=1:5 %solve ode. Stop after nstep steps  to compute error
  for n=1:nstep
    [y,f] = method(xn,h,y,f); %compute solution at x+h
    xn = xn+h;
  end
  x(k) = xn-p*h; %x-value where error is computed.
  err(k) = norm(y(:,1) - exact_sol_linear_ivp(x(k), A, a, eta));%compute error
  c(k) = count;%function evaluations needed so far
end
z=[x' err' c'];
disp('      x       error   evaluations of f(x,y)')
disp(z)


%-------- Cut here -----------------------------------------------

%M-file method.m (This file implements a 
%general linear multistep method). 

function [y,f]=method(x,h,y,f)
% [y,f]=method(x,h,y,f) computes one step of a general linear multistep method.
% y = matrix whose (j+1)st column is y_{n-p+j), j=0,...,p
% f = matrix whose (j+1)st column is f(x_{n-p+j},y_{n-p+j}), j=0,...,p
% On output, the (J+1)st columns of y and f are y_{n+1-p+j) and 
% f(x{n+1-p+j},y_{n+1-p+j}), respectively.
% Here x_{n-p+j} = x + (j-p)*h.
% To use a different method, change the column vectors alpha and beta.

%Specify the parameters alpha and beta in column vectors. 
%Note that since MATLAB does not allow for 0 indices, you must set
%alpha(j+1) = alpha_j, beta(j+1) = beta_j, j=0,...,p+1, 

alpha=[-3/4; -1/2; 1/4; 1];      % Example: y_{n+1}-y_{n} = 
beta=(1/8)*[5; 0;19; 0]; % (h/3)*[3*f(x_{n},y_{n}) - 2*f(x_{n-1},y_{n-1})] 


p = max(size(alpha)) - 2;
a1 = -alpha(1:p+1)/alpha(p+2);
b1 = h*beta(1:p+1)/alpha(p+2);

tmp = y*a1+ f*b1; %Computes sum_{j=0}^p  [-alpha_j y_{n-p+j) +
                  %             +h*beta_j*f(x_{n-p+j},y_{n-p+j})]/alpha(p+2)

if (beta(p+2) == 0) %method is explicit.
  y1 = tmp;

else  % method implicit. Use fixed point iteration to solve the equation 
      % y1 = tmp + h*beta(p+2)*f(x+h,y1)/alpha(p+2), with tmp as above.

  tol = 1.e-5; itmax = 100; %specify tolerance and maximum # of iterations
  bp2 = h*beta(p+2)/alpha(p+2);xh = x+h;%auxiliary variables  
  y0 = y(:,p+1); %starting vector for iteration
  t1 = 2*tol; t2=0;iter = 0;%initialize parameters for stopping criterion.
  
  while ((t1 > tol*t2) & (iter < itmax)) %iteration loop
    y1 = tmp + bp2*fun(xh,y0);
    t1 = norm(y1-y0); t2 = norm(y1) + norm(y0); %evaluate stopping criterion
    iter = iter+1;
    y0 = y1;
  end

  if (iter == itmax) %print warning if iteration did not converge.
    disp('  ');
    disp('Slow or no convergence in fixed point iteration.')
    disp('  x    rel. err.    tolerance     iterations ')
    disp([x    t1/t2     tol   iter ])
  end    
end

y(:,1:p) = y(:,2:p+1);y(:,p+1)=y1; %update y
f(:,1:p) = f(:,2:p+1);f(:,p+1)=fun(x+h,y1); %update f
end

%-------- Cut here -----------------------------------------------
%M-file fun.m. implements f(x,y). 

function f=fun(x,y)
%derivatives for IVP 
global count;% counts how often fun is called
f = zeros(size(y));
A = [200 398 198; -500 -696 -296; 500 694 294];
f = A*y;
count = count+1;
end

%-------- Cut here -----------------------------------------------

%M-file exsolhw3.m computing exact solution:

function z = exsolhw3(x)
%exsolhw3(x) returns exact solution of IVP for homework problem 3
% in a column vector
tmp = 3*exp(-8*x);
z = [(1+tmp)/8; -tmp];
end














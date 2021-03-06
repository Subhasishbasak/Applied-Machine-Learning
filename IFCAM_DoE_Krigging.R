#IFCAM practical session Day 2
#TD3 : Design of Numerical Experiments
#Required R packages: DiceDesign, randtoolbox 

library(DiceDesign)

?mindist
A=matrix(runif(18),ncol=2)
mindist(A)
cr=0
for (i in 1:1000){
  A=matrix(runif(18),ncol=2)
  c1=mindist(A)
  if(c1>cr){
    A1=A
    cr=c1
  }
}
A1        #Gives the design
c1        #Gives the maximum of mindist

par(mfrow=c(1,2))
plot(A,main="Random allocation",cex=2)
plot(A1,main="Maxmin allocation",cex=2)


A2=factDesign(2,3)         #Full factorial design
A2$design

mindist(A2$design)
par(mfrow=c(2,2))
plot(A2$design,main="Full factorial",cex=2)


#####################################
library(randtoolbox)
A3=sobol(9,2)
plot(A3,main="Sobol allocation",cex=2)
mindist(A3)


print("Random")
print(discrepancyCriteria(A,type=c('M2','C2')))
print("Random maximin")
print(discrepancyCriteria(A1,type=c('M2','C2')))
print("Factorial")
print(discrepancyCriteria(A2$design,type=c('M2','C2')))
print("Sobol")
print(discrepancyCriteria(A3,type=c('M2','C2')))

#w.r.t discrepency measure(points per sub-vol by total vol) factorial design 
#..is worst. Sobol is the best.

A4=halton(200,8)
pairs(A4,pch=".",cex=3)      #Taking all possible 2D projections


A5=sobol(200,8)
pairs(A5,pch=".",cex=3)      #Taking all possible 2D projections

###################################################################

lhs <- function(N,p){
  ran = matrix(runif(N*p),nrow=N,ncol=p)   # tirage de N x p valeurs selon loi U[0,1]
  x = matrix(0,nrow=N,ncol=p)  # construction de la matrice x
  
  for (i in 1:p) {
    idx = sample(1:N)        # vecteur de permutations des entiers {1,2,.,N}
    P = (idx-ran[,i]) / N    # vecteur de probabilitÚs
    x[,i] <- qunif(P)  }
  return(x)}


#method (i)
cr=0
for (i in 1:1000){
  A=lhs(20,2)
  c1=mindist(A)
  if(c1>cr){
    L_1=A
    cr=c1
  }
}
L_1          #Gives the design
c1           #Gives the maximum of mindist

plot(L_1,main="Latin Hypercube Design")

#########################################################
#TD3 : Design of Numerical Experiments
#Required R packages:DiceKriging, DiceView 

set.seed(12345) 

myfunc <- function(x){
  return( sin(30*(x - 0.9)^4)*cos(2*(x - 0.9)) + (x - 0.9)/2)
}

# vizualisation
ntest <- 1000
xtest <- seq(0,1,le=ntest)
ytest <- myfunc(xtest)


plot(xtest,ytest,type="l",xlab="x",ylab="y")

################
#b) Simple kriging

library(DiceKriging)
help(package="DiceKriging")
?km

x=seq(0,1,.25)
y=myfunc(x)
points(x,y)

mu=0
sig2=0.5
theta=0.2

krig=km(~1,design = data.frame(x=x),response = y,covtype = "gauss",coef.trend = mu,
        coef.var = sig2,coef.cov = theta)


ypred=predict(krig,xtest,type = "SK",checkNames=F)
Q2 = 1 - mean((ytest-ypred$mean)^2)/var(ytest)
print(Q2)
names(ypred)

# plot the kriging model
x11()
plot(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2,
     main="kriging predictions",ylim=c(min(ypred$lower95),max(ypred$upper95)))
points(x,y,col=2,pch=2,lwd=2)
lines(xtest,ypred$mean,col=4,lwd=2)
lines(xtest,ypred$lower95,col=4,lty=2)
lines(xtest,ypred$upper95,col=4,lty=2)

# using DiceView
library(DiceView)

x11()
sectionview(krig,ylim=c(min(ypred$lower95),max(ypred$upper95)))
lines(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2)

######################################
#Kriging with unknown hyperparameters



#Part(i) : 7 partitions; mu,sig2,cov specified in Gaussian model
x=seq(0,1,le=7)
y=myfunc(x)
points(x,y)


krig=km(~1,design = data.frame(x=x),response = y,covtype = "gauss",coef.trend = mu,
        coef.var = sig2,coef.cov = theta)


ypred=predict(krig,xtest,type = "UK",checkNames=F)
Q2 = 1 - mean((ytest-ypred$mean)^2)/var(ytest)
print(Q2)
names(ypred)

# plot the kriging model
x11()
plot(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2,
     main="kriging predictions",ylim=c(min(ypred$lower95),max(ypred$upper95)))
points(x,y,col=2,pch=2,lwd=2)
lines(xtest,ypred$mean,col=4,lwd=2)
lines(xtest,ypred$lower95,col=4,lty=2)
lines(xtest,ypred$upper95,col=4,lty=2)

sectionview(krig,ylim=c(min(ypred$lower95),max(ypred$upper95)))
lines(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2)

#Part(ii) : 7 partitions; mu,sig2,cov NOT-specified in Marten5_2 & Marten5_2 model
x=seq(0,1,le=7)
y=myfunc(x)
points(x,y)


krig=km(~1,design = data.frame(x=x),response = y,covtype = "matern5_2")


ypred=predict(krig,xtest,type = "UK",checkNames=F)
Q2 = 1 - mean((ytest-ypred$mean)^2)/var(ytest)
print(Q2)
names(ypred)

# plot the kriging model
x11()
plot(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2,
     main="kriging predictions",ylim=c(min(ypred$lower95),max(ypred$upper95)))
points(x,y,col=2,pch=2,lwd=2)
lines(xtest,ypred$mean,col=4,lwd=2)
lines(xtest,ypred$lower95,col=4,lty=2)
lines(xtest,ypred$upper95,col=4,lty=2)

sectionview(krig,ylim=c(min(ypred$lower95),max(ypred$upper95)))
lines(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2)


###############################################################
#Adaptive model : adding total 4 points 
for(i in 1:4){
xadd=which.max(ypred$sd)/ntest
yadd=myfunc(xadd)
x=c(x,xadd)
y=c(y,yadd)
krig=km(~1,design = data.frame(x=x),response = y,covtype = "matern5_2")
ypred=predict(krig,xtest,type = "UK",checkNames=F)
Q2 = 1 - mean((ytest-ypred$mean)^2)/var(ytest)
print(Q2)
sectionview(krig,ylim=c(min(ypred$lower95),max(ypred$upper95)))
lines(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2)
}


################
#5) Quantile estimation

# nx <- 8
# x <- seq(0,1,le=nx)
# y <- myfunc(x)
# krig <- km(~1,design=data.frame(x=x), response=y, covtype="matern5_2")
# ypred <- predict(object=krig, newdata=xtest, type="SK", checkNames=F)

x11()
sectionview(krig,ylim=c(min(ypred$lower95),max(ypred$upper95)))
lines(xtest,ytest,type="l",xlab="x",ylab="y",lwd=2)

alpha <- 0.9

q1 = quantile(ytest,alpha)
print(c("True quantile = ",q1))
abline(h=q1)

q2 = quantile(ypred$mean,alpha)
print(c("Kriging quantile = ",q2))
abline(h=q2,col=4)

nsim = 1e4
zsim = simulate(krig,nsim=nsim,cond=TRUE,newdata=data.frame(x=xtest),nugget.sim=1e-5)
q=rep(0,nsim)
for (i in 1:nsim){
  q[i] = quantile(zsim[i,],alpha)
}
for (i in 1:10) lines(xtest,zsim[i,],col=2)

q3 = mean(q)
print(c("Quantile by conditional simul. =",q3))
abline(h=q3,col=2)

res <- quantile(q,c(0.05,0.95))
print(c("Quantile with 90%-confidence interval =",res))

# Histogram of the output
x11()
hist(ytest)
abline(v=q1)
abline(v=q2,col=4)
abline(v=q3,col=2)


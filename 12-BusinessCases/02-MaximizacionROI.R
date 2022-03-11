library(lpSolve)

# Función objetivo: Anotamos los coeficientes de la función objetivo que queremos maximizar o minimizar, 
# en este caso el ROI de cada medio
f.objective <- c(0.25, 0.18, 0.10)
names(f.objective) <- c('Google Ads', 'Facebook Ads', 'Instagram Ads')

f.objective

# Creamos una matriz con los coeficientes de las restricciones del modelo
f.constraints <- matrix(c(1,1,1,
                          0.45, -0.55, -0.55,
                          -0.55, 0.45, 0.45,
                          0, -1, 0,
                          0, 0, -1,
                          29.41, 40, 62.5), nrow = 6, byrow = TRUE)

# Indicamos los signos de igualdad de las restricciones
f.logic_direction <- c("<=",
                       "<=",
                       "<=",
                       "<=",
                       "<=",
                       "<="
)

# RHS o "Right hand side": los valores de las restricciones
f.decision_factor <- c(50000,
                       0,
                       0,
                       -5000,
                       -2500,
                       1500000)

# Ejecutamos el proceso de maximización de (z), nuestra función objetivo
resultado <- lp(direction = "max", 
                objective.in = f.objective, const.mat = f.constraints, const.dir = f.logic_direction, const.rhs= f.decision_factor)

resultado

# ¿Cuánto invierto en cada plataforma?
resultado$solution

# Hemos alcanzado el total del presupuesto?
sum(resultado$solution) == 50000

# Qué presupuesto queda libre
50000 - sum(resultado$solution)


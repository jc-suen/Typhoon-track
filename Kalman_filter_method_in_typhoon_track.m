% Kalman filter parameters
dt = 1; % time step
Q = 0.1; % process noise
R = 1; % measurement noise
A = [1 dt; 0 1]; % state transition matrix
B = [0.5*dt^2; dt]; % control input matrix
C = [1 0]; % measurement matrix

% Initial state estimation
x_hat = [0; 0]; % initial state estimate
P = [1 0; 0 1]; % initial state covariance

% Simulated typhoon position and velocity data
t = 0:dt:100;
v = 10 + 5*sin(t/10); % simulate changing typhoon velocity
x_true = [0; cumsum(v)*dt]; % simulate changing typhoon position

% Generate noisy measurements
y = x_true(1,:) + sqrt(R)*randn(size(x_true(1,:)));

% Kalman filter loop
for i = 1:length(t)
    
    % State prediction
    x_pred = A*x_hat + B*v(i);
    P_pred = A*P*A' + Q;
    
    % Measurement update
    K = P_pred*C'/(C*P_pred*C' + R);
    x_hat = x_pred + K*(y(i) - C*x_pred);
    P = (eye(2) - K*C)*P_pred;
    
    % Save estimated position and velocity
    x_est(:,i) = x_hat;
    v_est(i) = x_hat(2);
end

% Plot true and estimated typhoon position and velocity
figure;
subplot(2,1,1);
plot(t, x_true(1,:), 'b', t, x_est(1,:), 'r');
xlabel('Time (s)');
ylabel('Position (km)');
legend('True position', 'Estimated position');
subplot(2,1,2);
plot(t, v, 'b', t, v_est, 'r');
xlabel('Time (s)');
ylabel('Velocity (km/s)');
legend('True velocity', 'Estimated velocity');

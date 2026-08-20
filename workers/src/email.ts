export interface EmailTemplate {
  to: string[];
  subject: string;
  template: string;
  data: Record<string, any>;
}

export async function sendEmail(
  email: EmailTemplate,
  sendgridApiKey: string
): Promise<boolean> {
  try {
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${sendgridApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: email.to.map((address) => ({
          to: [{ email: address }],
        })),
        from: {
          email: 'accountability@unscroll.app',
          name: 'UnScroll',
        },
        subject: email.subject,
        content: [
          {
            type: 'text/html',
            value: renderTemplate(email.template, email.data),
          },
        ],
      }),
    });

    return response.status === 202;
  } catch (error) {
    console.error('SendGrid error:', error);
    return false;
  }
}

function renderTemplate(template: string, data: Record<string, any>): string {
  if (template === 'weekly_summary') {
    return renderWeeklySummary(data);
  }
  return '';
}

function renderWeeklySummary(data: Record<string, any>): string {
  const stats = data.stats || {};
  const userName = data.user_name || 'User';
  const week = data.week || 'this week';

  return `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { text-align: center; margin-bottom: 30px; }
    .stats { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }
    .stat-card { background: #f5f5f5; padding: 20px; border-radius: 8px; }
    .stat-value { font-size: 32px; font-weight: bold; color: #00a3ff; }
    .stat-label { color: #666; font-size: 14px; margin-top: 8px; }
    .footer { text-align: center; color: #999; font-size: 12px; margin-top: 30px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📊 ${userName}'s Weekly Summary</h1>
      <p>Your accountability report for ${week}</p>
    </div>

    <div class="stats">
      <div class="stat-card">
        <div class="stat-value">${stats.blocked_attempts || 0}</div>
        <div class="stat-label">Blocked Attempts</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${stats.panic_activations || 0}</div>
        <div class="stat-label">Panic Activations</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${stats.adherence_rate || 0}%</div>
        <div class="stat-label">Adherence Rate</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">${stats.allowed_attempts || 0}</div>
        <div class="stat-label">Times Disabled</div>
      </div>
    </div>

    <p style="text-align: center; margin-top: 30px;">
      <strong>You're doing great! Keep up the focus! 💪</strong>
    </p>

    <div class="footer">
      <p>This is your weekly accountability summary from UnScroll.</p>
      <p>Your accountability partner received a summary of your progress.</p>
    </div>
  </div>
</body>
</html>
  `;
}

export function renderAccountabilityEmail(
  userStats: Record<string, any>,
  userName: string
): string {
  return `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>Accountability Update: ${userName}</h2>
    <p>Your accountability partner has shared their weekly stats with you:</p>
    
    <ul>
      <li>Blocked Attempts: ${userStats.blocked_attempts}</li>
      <li>Panic Activations: ${userStats.panic_activations}</li>
      <li>Adherence Rate: ${userStats.adherence_rate}%</li>
    </ul>
    
    <p>Keep supporting each other on this journey to digital wellness!</p>
  </div>
</body>
</html>
  `;
}

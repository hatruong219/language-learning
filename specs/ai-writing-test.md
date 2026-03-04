# AI Writing Test Feature

## Overview
This feature introduces a writing test functionality where users can:
1. Receive random writing prompts from the database.
2. Submit their written responses.
3. Have their responses automatically graded using an AI API.

## Key Components

### Writing Prompts
- Prompts will be stored in the database.
- Example prompts:
  - Describe yourself.
  - Describe your family.
  - Discuss your personal hobbies.

### User Flow
1. **Prompt Generation**:
   - A random writing prompt is fetched from the database.
   - Displayed to the user.
2. **User Submission**:
   - User writes and submits their response.
3. **AI Grading**:
   - The system sends the user's response to an AI API for grading.
   - The AI returns a score and feedback.
4. **Result Display**:
   - The score and feedback are displayed to the user.

## Database Changes
### New Table: `writing_prompts`
- **Columns**:
  - `id` (UUID, Primary Key)
  - `site_id` (UUID, Foreign Key → `sites(id)`)
  - `prompt` (Text)
  - `created_at` (Timestamp)

### New Table: `writing_submissions`
- **Columns**:
  - `id` (UUID, Primary Key)
  - `site_id` (UUID, Foreign Key → `sites(id)`)
  - `prompt_id` (UUID, Foreign Key → `writing_prompts(id)`)
  - `user_id` (UUID, Foreign Key → `users(id)`)
  - `response` (Text)
  - `score` (Integer, Nullable)
  - `feedback` (Text, Nullable)
  - `created_at` (Timestamp)

## API Endpoints

### `GET /api/writing-prompts/random`
- **Description**: Fetch a random writing prompt.
- **Response**:
  ```json
  {
    "id": "uuid",
    "prompt": "Describe yourself."
  }
  ```

### `POST /api/writing-submissions`
- **Description**: Submit a written response.
- **Request Body**:
  ```json
  {
    "prompt_id": "uuid",
    "user_id": "uuid",
    "response": "My name is..."
  }
  ```
- **Response**:
  ```json
  {
    "submission_id": "uuid",
    "status": "submitted"
  }
  ```

### `POST /api/writing-submissions/grade`
- **Description**: Grade a submission using the AI API.
- **Request Body**:
  ```json
  {
    "submission_id": "uuid"
  }
  ```
- **Response**:
  ```json
  {
    "score": 85,
    "feedback": "Great structure and vocabulary."
  }
  ```

## Frontend Changes

### New Page: `/writing-test`
- **Features**:
  - Display a random writing prompt.
  - Text area for user response.
  - Submit button.

### New Page: `/writing-test/results`
- **Features**:
  - Display the score and feedback.

## AI Integration
- **API**: Use a third-party AI service for grading (e.g., OpenAI, Claude).
- **Process**:
  - Send the user's response to the AI API.
  - Receive a score and feedback.

## Tasks
1. Create database migrations for `writing_prompts` and `writing_submissions`.
2. Implement backend API endpoints.
3. Develop frontend pages for the writing test and results.
4. Integrate AI API for grading.
5. Write unit and integration tests.
6. Deploy and test the feature.
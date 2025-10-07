defmodule StackoverflowCloneWeb.SearchComponents do
  use Phoenix.Component
  import StackoverflowCloneWeb.CoreComponents

  attr :query, :string, required: true
  attr :loading, :boolean, default: false

  def search_form(assigns) do
    ~H"""
    <form phx-submit="search" class="w-full">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
          <svg
            class="h-5 w-5 text-gray-400"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fill-rule="evenodd"
              d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
              clip-rule="evenodd"
            />
          </svg>
        </div>
        <input
          type="text"
          name="query"
          value={@query}
          phx-change="update_query"
          placeholder="Search for questions..."
          class="block w-full bg-white border border-gray-300 rounded-lg py-3 pl-12 pr-32 text-indigo-500 text-sm placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent shadow-sm"
          disabled={@loading}
        />
        <button
          type="submit"
          disabled={@loading}
          class="absolute right-2 top-1/2 transform -translate-y-1/2 bg-indigo-600 text-white px-6 py-2 rounded-md hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed font-semibold text-sm transition-colors shadow-sm"
        >
          <%= if @loading do %>
            <.icon name="hero-arrow-path" class="h-5 w-5 animate-spin" />
          <% else %>
            Search
          <% end %>
        </button>
      </div>
    </form>
    """
  end

  attr :recent_searches, :list, required: true

  def recent_searches_sidebar(assigns) do
    ~H"""
    <nav class="flex flex-col space-y-1">
      <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wider">
        Recent Searches
      </div>
      <%= if @recent_searches == [] do %>
        <div class="px-3 py-2 text-sm text-gray-500">
          No recent searches
        </div>
      <% else %>
        <%= for search <- @recent_searches do %>
          <button
            phx-click="select_recent_search"
            phx-value-search-id={search.id}
            class="flex items-center gap-3 px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-md transition-colors text-left"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"
                clip-rule="evenodd"
              />
            </svg>
            <span class="truncate"><%= search.query_text %></span>
          </button>
        <% end %>
      <% end %>
    </nav>
    """
  end

  attr :question, :map, required: true
  attr :answers, :list, required: true
  attr :llm_ranked_answers, :list, required: true
  attr :active_tab, :string, required: true
  attr :llm_loading, :boolean, default: false

  def question_display(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Question Card -->
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div class="p-6">
          <div class="flex gap-6">
            <!-- Vote Section -->
            <div class="flex flex-col items-center space-y-2 flex-shrink-0 w-16">
              <button class="text-gray-400 hover:text-indigo-600 transition-colors">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-8 w-8"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z"
                    clip-rule="evenodd"
                  />
                </svg>
              </button>
              <div class="font-semibold text-2xl text-gray-900"><%= @question.score %></div>
              <div class="text-xs text-gray-500">votes</div>
              <button class="text-gray-400 hover:text-indigo-600 transition-colors">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-8 w-8"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                    clip-rule="evenodd"
                  />
                </svg>
              </button>
            </div>
            <!-- Content -->
            <div class="flex-1 min-w-0">
              <h2 class="text-2xl font-bold text-gray-900 mb-4"><%= @question.title %></h2>

              <%= if @question.body do %>
                <div class="prose max-w-none mb-6 text-gray-700 leading-relaxed">
                  <%= Phoenix.HTML.raw(sanitize_html(@question.body)) %>
                </div>
              <% end %>
              <!-- Tags and Meta Info -->
              <div class="flex flex-wrap items-center gap-3 mb-4">
                <%= if @question.tags && length(@question.tags) > 0 do %>
                  <%= for tag <- @question.tags do %>
                    <span class="bg-indigo-100 text-indigo-800 text-xs font-medium px-2.5 py-0.5 rounded-full">
                      <%= tag %>
                    </span>
                  <% end %>
                <% end %>
              </div>
              <!-- Stats -->
              <div class="flex items-center gap-4 text-sm text-gray-500 mb-4">
                <span><%= @question.answer_count %> answers</span>
                <span><%= @question.view_count %> views</span>
              </div>
              <!-- Author and Link -->
              <div class="flex items-center justify-between pt-4 border-t border-gray-100">
                <div class="text-sm text-gray-600">
                  Asked by
                  <span class="font-medium text-indigo-600">
                    <%= @question.owner_display_name || "Anonymous" %>
                  </span>
                  <%= if @question.owner_reputation do %>
                    <span class="text-gray-500">(reputation: <%= @question.owner_reputation %>)</span>
                  <% end %>
                </div>

                <a
                  href={@question.link}
                  target="_blank"
                  class="text-indigo-600 hover:text-indigo-700 text-sm font-semibold flex items-center gap-1"
                >
                  View on Stack Overflow
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z" />
                    <path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z" />
                  </svg>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- Answers Section -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="border-b border-gray-200">
          <.answer_tabs
            active_tab={@active_tab}
            has_llm_rankings={length(@llm_ranked_answers) > 0}
            llm_loading={@llm_loading}
            answer_count={length(@answers)}
          />
        </div>

        <div class="p-6">
          <%= if @active_tab == "original" do %>
            <.answers_list answers={@answers} />
          <% else %>
            <%= if @llm_loading do %>
              <div class="flex items-center justify-center py-16">
                <.icon name="hero-arrow-path" class="h-8 w-8 animate-spin text-indigo-600" />
                <span class="ml-3 text-gray-600 font-medium">LLM is ranking answers...</span>
              </div>
            <% else %>
              <%= if length(@llm_ranked_answers) > 0 do %>
                <.llm_ranked_answers_list llm_ranked_answers={@llm_ranked_answers} />
              <% else %>
                <div class="text-center py-16">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-16 w-16 text-gray-300 mx-auto mb-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
                    />
                  </svg>
                  <p class="text-gray-600 mb-6 text-lg">LLM ranking not available yet</p>
                  <button
                    phx-click="trigger_llm_ranking"
                    class="bg-indigo-600 text-white px-8 py-3 rounded-lg hover:bg-indigo-700 font-semibold shadow-sm transition-colors"
                  >
                    Rank with LLM
                  </button>
                </div>
              <% end %>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :active_tab, :string, required: true
  attr :has_llm_rankings, :boolean, required: true
  attr :llm_loading, :boolean, required: true
  attr :answer_count, :integer, required: true

  def answer_tabs(assigns) do
    ~H"""
    <nav class="flex space-x-8 px-6" aria-label="Tabs">
      <button
        phx-click="switch_tab"
        phx-value-tab="original"
        class={[
          "py-4 px-1 border-b-2 font-semibold text-sm whitespace-nowrap transition-colors",
          if(@active_tab == "original",
            do: "border-indigo-600 text-indigo-600",
            else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          )
        ]}
      >
        Original Ranking (<%= @answer_count %>)
      </button>

      <button
        phx-click="switch_tab"
        phx-value-tab="llm_ranked"
        class={[
          "py-4 px-1 border-b-2 font-semibold text-sm whitespace-nowrap flex items-center transition-colors",
          if(@active_tab == "llm_ranked",
            do: "border-indigo-600 text-indigo-600",
            else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          )
        ]}
      >
        LLM Ranked
        <%= if @llm_loading do %>
          <.icon name="hero-arrow-path" class="ml-2 h-4 w-4 animate-spin" />
        <% end %>
        <%= if @has_llm_rankings do %>
          <span class="ml-2 bg-green-100 text-green-800 text-xs px-2 py-0.5 rounded-full font-semibold">
            ✓
          </span>
        <% end %>
      </button>
    </nav>
    """
  end

  attr :answers, :list, required: true

  def answers_list(assigns) do
    ~H"""
    <div class="space-y-6">
      <h3 class="text-xl font-bold text-gray-900 mb-6">
        <%= length(@answers) %> <%= if length(@answers) == 1, do: "Answer", else: "Answers" %>
      </h3>

      <%= for answer <- @answers do %>
        <.answer_card answer={answer} />
      <% end %>
    </div>
    """
  end

  attr :answer, :map, required: true

  def answer_card(assigns) do
    ~H"""
    <div class="border-t border-gray-200 pt-6 first:border-t-0 first:pt-0">
      <div class="flex gap-6">
        <!-- Vote Section -->
        <div class="flex flex-col items-center space-y-2 flex-shrink-0 w-16">
          <button class="text-gray-400 hover:text-indigo-600 transition-colors">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z"
                clip-rule="evenodd"
              />
            </svg>
          </button>
          <div class="font-semibold text-xl text-gray-900"><%= @answer.score %></div>
          <button class="text-gray-400 hover:text-indigo-600 transition-colors">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                clip-rule="evenodd"
              />
            </svg>
          </button>
          <%= if @answer.is_accepted do %>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-8 w-8 text-green-500 mt-2"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              />
            </svg>
          <% end %>
        </div>
        <!-- Content -->
        <div class="flex-1 min-w-0">
          <div class="prose max-w-none text-gray-700 leading-relaxed">
            <%= Phoenix.HTML.raw(sanitize_html(@answer.body)) %>
          </div>

          <div class="mt-6 pt-4 border-t border-gray-100 text-sm text-gray-600">
            Answered by
            <span class="font-medium text-indigo-600">
              <%= @answer.owner_display_name || "Anonymous" %>
            </span>
            <%= if @answer.owner_reputation do %>
              <span class="text-gray-500">(reputation: <%= @answer.owner_reputation %>)</span>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :llm_ranked_answers, :list, required: true

  def llm_ranked_answers_list(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-xl font-bold text-gray-900">
          LLM Ranked Answers
        </h3>
        <span class="text-sm text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
          Ranked by <%= Enum.at(@llm_ranked_answers, 0).llm_model_used %>
        </span>
      </div>

      <%= for ranked <- @llm_ranked_answers do %>
        <.llm_ranked_answer_card ranked={ranked} />
      <% end %>
    </div>
    """
  end

  attr :ranked, :map, required: true

  def llm_ranked_answer_card(assigns) do
    ~H"""
    <div class="border-t border-gray-200 pt-6 first:border-t-0 first:pt-0">
      <div class="flex gap-6">
        <!-- Rank Badge -->
        <div class="flex flex-col items-center space-y-2 flex-shrink-0">
          <div class="bg-indigo-600 text-white rounded-lg w-14 h-14 flex items-center justify-center font-bold text-xl shadow-md">
            #<%= @ranked.llm_rank %>
          </div>
          <%= if @ranked.llm_confidence_score do %>
            <span class="text-xs text-gray-600 font-semibold bg-gray-100 px-2 py-1 rounded">
              <%= Float.round(@ranked.llm_confidence_score * 100, 0) %>%
            </span>
          <% end %>
        </div>

        <div class="flex-1 min-w-0">
          <!-- LLM Reasoning -->
          <%= if @ranked.llm_reasoning do %>
            <div class="mb-4 p-4 bg-indigo-50 border-l-4 border-indigo-500 rounded-r-lg">
              <p class="text-sm text-indigo-900 leading-relaxed">
                <span class="font-semibold">LLM Analysis:</span> <%= @ranked.llm_reasoning %>
              </p>
            </div>
          <% end %>
          <!-- Answer Content -->
          <div class="flex gap-6">
            <div class="flex flex-col items-center space-y-2 flex-shrink-0 w-16">
              <div class="font-semibold text-xl text-gray-900"><%= @ranked.answer.score %></div>
              <div class="text-xs text-gray-500">votes</div>
              <%= if @ranked.answer.is_accepted do %>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6 text-green-500 mt-1"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clip-rule="evenodd"
                  />
                </svg>
              <% end %>
            </div>

            <div class="flex-1 min-w-0">
              <div class="prose max-w-none text-gray-700 leading-relaxed">
                <%= Phoenix.HTML.raw(sanitize_html(@ranked.answer.body)) %>
              </div>

              <div class="mt-6 pt-4 border-t border-gray-100 text-sm text-gray-600">
                Answered by
                <span class="font-medium text-indigo-600">
                  <%= @ranked.answer.owner_display_name || "Anonymous" %>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def loading_state(assigns) do
    ~H"""
    <div class="flex items-center justify-center py-24">
      <div class="text-center">
        <.icon name="hero-arrow-path" class="h-12 w-12 animate-spin text-indigo-600 mx-auto" />
        <p class="mt-6 text-lg text-gray-600 font-medium">Searching Stack Overflow...</p>
      </div>
    </div>
    """
  end

  attr :error, :string, required: true

  def error_state(assigns) do
    ~H"""
    <div class="bg-red-50 border border-red-200 rounded-lg p-6">
      <div class="flex">
        <.icon name="hero-exclamation-circle" class="h-6 w-6 text-red-600" />
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">Error</h3>
          <p class="mt-2 text-sm text-red-700"><%= @error %></p>
        </div>
      </div>
    </div>
    """
  end

  def empty_state(assigns) do
    ~H"""
    <div class="text-center py-24">
      <.icon name="hero-magnifying-glass" class="h-16 w-16 text-gray-400 mx-auto" />
      <h3 class="mt-4 text-lg font-medium text-gray-900">Search Stack Overflow</h3>
      <p class="mt-2 text-sm text-gray-500">
        Enter a question above to search for answers
      </p>
    </div>
    """
  end

  defp sanitize_html(html) do
    HtmlSanitizeEx.basic_html(html)
  end
end

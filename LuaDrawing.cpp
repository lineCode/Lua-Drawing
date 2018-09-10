#ifndef SDL_HH
    #define SDL_HH
    #include <SDL2/SDL.h>
#endif

//#define TTF_SUPPORT

#ifdef TTF_SUPPORT
  #ifndef SDL_TTF_HH
    #define SDL_TTF_HH
    #include <SDL2/SDL_ttf.h>
 #endif
#endif

#ifndef LUA_FUNCTION_H
    #include "../Lua-Adapter/LuaFunction.hpp"
#endif


SDL_Renderer* renderer {nullptr};
SDL_Color Color_foreground{0, 0, 0, 255};
SDL_Color Color_background{255, 255, 255, 255};

#ifdef TTF_SUPPORT
TTF_Font * font{nullptr};
class Label {
 public:
  Label(std::string Text = "", int X = 100, int Y = 100)
      : texture{nullptr}, box{X, Y, 0, 0}, text{Text} {}
  ~Label() {}
  SDL_Texture *texture;
  SDL_Rect box;
  std::string text;

  bool create(SDL_Renderer *const renderer, TTF_Font *const font, const SDL_Color &color_text){
    SDL_Surface *const surface{TTF_RenderUTF8_Blended(font, this->text.c_str(), color_text)};
    if (!surface) {
      std::cout << "Surface Error! \n";
      return false;
    }
    this->texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);
    if (!this->texture) {
      std::cout << "Texture Error! \n";
      return false;
    }
    SDL_QueryTexture(this->texture, NULL, NULL, &this->box.w, &this->box.h);
   return true;
  }
};

static int draw_label(lua_State *L) {
  if(!L)
    return 1;
  std::string text {lua_tostring(L, 1)};
   int x1 {lua_tonumber(L, 2)};
  int y1 {lua_tonumber(L, 3)};
  Label l{text, x1, y1};
  l.create(renderer, font, Color_foreground);
  SDL_RenderCopy(renderer, l.texture, NULL, &l.box);
  return 0;
}
#endif

static int clear_background(lua_State *L) {
  SDL_SetRenderDrawColor(renderer, Color_background.r, Color_background.g, Color_background.b, Color_background.a);
  SDL_RenderClear(renderer);
  return 0;
}

int set_color(lua_State *L) {
    if(!L)
        return 1;
    const unsigned char r {(unsigned char)(lua_tointeger(L, 1))};
    const unsigned char g {(unsigned char)(lua_tointeger(L, 2))};
    const unsigned char b {(unsigned char)(lua_tointeger(L, 3))};
    const unsigned char a {(unsigned char)(lua_tointeger(L, 4))};
    Color_foreground = SDL_Color{r, g, b, a};
    SDL_SetRenderDrawColor(renderer, r, g, b, a);
    return 0;
}

int set_background(lua_State *L) {
    if(!L)
        return 1;
    const unsigned char r {(unsigned char)(lua_tointeger(L, 1))};
    const unsigned char g {(unsigned char)(lua_tointeger(L, 2))};
    const unsigned char b {(unsigned char)(lua_tointeger(L, 3))};
    const unsigned char a {(unsigned char)(lua_tointeger(L, 4))};
    Color_background = SDL_Color{r, g, b, a};
    clear_background(nullptr);
    return 0;
}

int fill_rect(lua_State *L) {
  if(!L)
    return 1;
  const SDL_Rect rect {
      lua_tointeger(L, 1),
      lua_tointeger(L, 2),
      lua_tointeger(L, 3),
      lua_tointeger(L, 4)
  };
  SDL_RenderFillRect(renderer, &rect);
  return 0;
}

int draw_rect(lua_State *L) {
  if(!L)
    return 1;
  const SDL_Rect rect {
      lua_tointeger(L, 1),
      lua_tointeger(L, 2),
      lua_tointeger(L, 3),
      lua_tointeger(L, 4)
  };
  SDL_RenderDrawRect(renderer, &rect);
  return 0;
}

int render(lua_State *L) {
  SDL_RenderPresent(renderer);
  return 0;
}

int delay(lua_State *L) {
  if(!L)
    return 1;
     struct timespec time_spec;

    time_spec.tv_sec = lua_tointeger(L, 1);
    time_spec.tv_nsec = lua_tointeger(L, 2);

    nanosleep(&time_spec, nullptr);
    return 0;
}

int main( ){
    constexpr unsigned short int DEFAULT_SCREEN_WIDTH = 800;
    constexpr unsigned short int DEFAULT_SCREEN_HEIGHT = 480;
    const std::string FILE_APPLICATION {"app.lua"};

    LuaAdapter lua;
    LuaFunction function{lua};
    if( (function.Push(fill_rect, "fill_rect") == false)
    or  (function.Push(draw_rect, "draw_rect") == false)
    or  (function.Push(set_color, "set_color") == false)
    or  (function.Push(set_background, "set_background") == false)
#ifdef TTF_SUPPORT
    or  (function.Push(draw_label, "draw_label") == false)
#endif
    or  (function.Push(clear_background, "clear_background") == false)
    or  (function.Push(render, "render") == false)
    or  (function.Push(delay, "delay") == false)
    )   {
        std::cout << "Error: Could not push C-Functions to Lua!";
    }

    if(lua.Load(FILE_APPLICATION)==false){
        std::cout << "Error: Could not load '"<< FILE_APPLICATION << "'!";
        return 1;
    }
    signed int SCREEN_WIDTH {DEFAULT_SCREEN_WIDTH};
    if(lua.Get("SCREEN_WIDTH", SCREEN_WIDTH)== false)
        std::cout << "Error: Could not load 'SCREEN_WIDTH' from Lua!";

    signed int SCREEN_HEIGHT {DEFAULT_SCREEN_HEIGHT};
    if(lua.Get("SCREEN_HEIGHT", SCREEN_HEIGHT) == false)
        std::cout << "Error: Could not load 'SCREEN_HEIGHT' from Lua!";

    if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 ) {
        return 1;
    }

    SDL_Window *window {
        SDL_CreateWindow(
            "Lua-Render v0.01",
            100, 100,
            SCREEN_WIDTH,
            SCREEN_HEIGHT,
            0
        )
    };
    if(!window) {
        SDL_Quit();
        std::cout << "Error: Could not open the window! \n";
        lua.Close();
        return 1;
    }

    renderer = SDL_CreateRenderer(
        window, -1,
        SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE
    );

    if(!renderer) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        std::cout << "Error: Could not create a rendering-context! \n";
        lua.Close();
        return 1;
    }

    SDL_RenderSetLogicalSize(
        renderer,
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    );

    function.Call("main");

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    lua.Close();
    return 0;
}

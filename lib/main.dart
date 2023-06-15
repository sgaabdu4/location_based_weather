import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

enum City {
  stockholm,
  paris,
  tokyo,
}

//Using typedef would help other programmers understand what type of string it would be
typedef WeatherEmoji = String;

//Future function - copuld be an API call that gets the weather
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
      const Duration(seconds: 1),
      () =>
          {
            City.stockholm: '❄️',
            City.paris: '☀️',
            City.tokyo: '🌧️',
          }[city] ??
          '💨');
}

const unknownWeatherEmoji = '🤷‍♂️';

//create a stateprovider that has the currentcity
//will be changed by the UI - UI writes to this and reads from it
final StateProvider<City?> currentCityProvider =
    StateProvider<City?>((ref) => null);

//create a weather providert that gets the current weather for that city
//UI will only read from this
final FutureProvider<String> weatherProvider =
    FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unknownWeatherEmoji;
  }
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch the current weather from the weather provider
    final AsyncValue<String> currentWeather = ref.watch(
      weatherProvider,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  //if currentdata has weather values then update the UI
                  currentWeather.when(
                data: (data) => Text(data),
                error: (Object error, StackTrace stackTrace) =>
                    Text(error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: City.values.length,
                    itemBuilder: (context, index) {
                      final city = City.values[index];
                      //if the city is the same as the currentcity provider then isSelected is true
                      final isSelected = city == ref.watch(currentCityProvider);
                      return ListTile(
                        title: Text(city.toString()),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        onTap: () {
                          //when the list tile is tapped then set the currentcityprovider value as the city selected.
                          ref.read(currentCityProvider.notifier).state = city;
                        },
                      );
                    }))
          ],
        ));
  }
}

// 1. The currentCityProvider is a StateProvider that holds the current city value. 
// It allows the UI to both read and modify the current city value.

// 2. The weatherProvider is a FutureProvider that fetches the weather emoji based on the current city. 
// It depends on the currentCityProvider and automatically updates whenever the current city value changes.

// 3. Inside the MyHomePage widget, the currentWeather variable is created by watching the weatherProvider. 
//It represents the current weather emoji and automatically updates based on the current city.

// 4. The UI is built to display the current weather emoji and a list of cities. 
//The weather emoji is displayed using currentWeather.when, which handles different states of the weather data (data, error, and loading).

// 5. The city list is generated using ListView.builder, and each city is represented as a ListTile. 
//The currently selected city is identified by comparing it with the value obtained from currentCityProvider.

// 6. When a city is tapped, the currentCityProvider is updated by modifying its state using the ref.read(currentCityProvider.notifier).state syntax. 
//This triggers a re-evaluation of the weatherProvider, fetching the corresponding weather emoji for the newly selected city.

// In summary, the currentCityProvider holds the current city, and the weatherProvider fetches the weather emoji based on the current city. 
//The UI watches the weatherProvider to display the current weather and allows the user to select a city, which updates the currentCityProvider and triggers a re-fetch of the weather emoji.
